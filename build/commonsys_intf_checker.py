#!/usr/bin/python
# -*- coding: utf-8 -*-
#Copyright (c) 2021 The Linux Foundation. All rights reserved.
#
#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions are
#met:
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above
#      copyright notice, this list of conditions and the following
#      disclaimer in the documentation and/or other materials provided
#      with the distribution.
#    * Neither the name of The Linux Foundation nor the names of its
#      contributors may be used to endorse or promote products derived
#      from this software without specific prior written permission.
#
#THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
#WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
#ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
#BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
#CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
#BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
#OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
#IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import os,json,sys
import subprocess
from xml.etree import ElementTree as et

module_info_dict = {}
git_project_dict = {}
out_path = os.getenv("OUT")
croot = os.getenv("ANDROID_BUILD_TOP")
violated_modules = []
git_repository_list = []
qssi_install_keywords = ["system","system_ext","product"]
vendor_install_keywords = ["vendor"]
violation_file_path = out_path


def parse_xml_file(path):
    xml_element = None
    if os.path.isfile(path):
        try:
            xml_element = et.parse(path).getroot()
            print(xml_element)
        except Exception as e:
            print("Exiting!! Xml Parsing Failed : " + path)
            sys.exit(1)
    else:
        print("Exiting!! File not Present : " + path)
        sys.exit(1)
    return xml_element

def load_json_file(path):
    json_dict = {}
    if os.path.isfile(path):
        json_file_handler = open(path,'r')
        try:
            json_dict = json.load(json_file_handler)
        except Exception as e:
            print("Exiting!! Json Loading Failed : " + path)
            sys.exit(1)
    else:
        print("Exiting!! File not Present : " + path)
        sys.exit(1)
    return json_dict

def check_if_module_contributing_to_qssi_or_vendor(install_path):
    qssi_path = False
    vendor_path = False
    installed_image = install_path.split(out_path.split(croot+"/")[1] + "/")[1]
    for qssi_keyword in qssi_install_keywords:
        if installed_image.startswith(qssi_keyword):
            qssi_path = True
            break
    if qssi_path:
        return {"qssi_path":qssi_path, "vendor_path":vendor_path}
    else:
        for vendor_keyword in vendor_install_keywords:
            if installed_image.startswith(vendor_keyword):
                vendor_path = True
                break
    return {"qssi_path":qssi_path, "vendor_path":vendor_path}

def find_and_update_git_project_path(path):
     for git_repository in git_repository_list:
         if git_repository in path:
             return git_repository
         else:
             return path

def print_violations_to_file(violation_list,qssi_path_project_list,vendor_path_project_list):
    ## Open file to write Violation list
    violation_file_handler = open(violation_file_path + "/commonsys-intf-violator.txt", "w")
    violation_file_handler.write("############ Violation List ###########\n\n")
    for violator in violation_list :
        qssi_module_list =  qssi_path_project_list[violator]
        vendor_module_list = vendor_path_project_list[violator]
        violation_file_handler.writelines("Git Project : " + violator+"\n")
        violation_file_handler.writelines("QSSI Violations \n")
        for qssi_module in qssi_module_list:
            violation_file_handler.writelines(qssi_module + ",")
        violation_file_handler.writelines("\nVendor Violations \n")
        for vendor_module in vendor_module_list:
            violation_file_handler.writelines(vendor_module  + ",")
        violation_file_handler.writelines("\n################################################# \n\n")
    violation_file_handler.close()

def find_commonsys_intf_project_paths():
    qssi_install_keywords = ["system","system_ext","product"]
    vendor_install_keywords = ["vendor"]
    path_keyword = "vendor"
    qssi_path_project_list={}
    vendor_path_project_list={}
    violation_list = {}
    for module in module_info_dict:
        try:
            install_path = module_info_dict[module]['installed'][0]
            project_path = module_info_dict[module]['path'][0]
        except IndexError:
            continue

        relative_out_path = out_path.split(croot + "/")[1]
        ## Ignore host and other paths
        if not relative_out_path in install_path:
            continue
        ## We are interested in only source paths which are
        ## starting with vendor for now.

        if project_path.startswith(path_keyword) and "@" not in module and "-ndk" not in module:
            qssi_or_vendor = check_if_module_contributing_to_qssi_or_vendor(install_path)
            if not qssi_or_vendor["qssi_path"] and not qssi_or_vendor["vendor_path"]:
                continue

            project_path = find_and_update_git_project_path(project_path)
            if qssi_or_vendor["qssi_path"]:
                install_path_list =  []
                if project_path in qssi_path_project_list:
                    install_path_list = qssi_path_project_list[project_path]
                install_path_list.append(install_path)
                qssi_path_project_list[project_path] = install_path_list
                 ## Check if path is present in vendor list as well , if yes then it will be a violation
                if project_path in vendor_path_project_list:
                    violation_list[project_path] = install_path
                continue

            if qssi_or_vendor["vendor_path"]:
                install_path_list =  []
                if project_path in vendor_path_project_list:
                    install_path_list = vendor_path_project_list[project_path]
                 #if not install_path in install_path_list:
                install_path_list.append(install_path)
                vendor_path_project_list[project_path] = install_path_list
                vendor_path = True
                ## Check if path is present in qssi list as well , if yes then it will be a violation
                if project_path in qssi_path_project_list:
                    violation_list[project_path] = install_path
    print_violations_to_file(violation_list,qssi_path_project_list,vendor_path_project_list)

def start_commonsys_intf_checker():
    global module_info_dict
    global git_repository_list
    global violation_file_path
    if os.path.exists(violation_file_path + "/configs"):
        violation_file_path = violation_file_path + "/configs"
    module_info_dict = load_json_file(out_path + "/module-info.json")
    manifest_root = parse_xml_file(croot + "/.repo/manifest.xml")
    for project in manifest_root.findall("project"):
        git_project_path = project.attrib.get('path')
        if not git_project_path == None:
            git_repository_list.append(git_project_path)
    find_commonsys_intf_project_paths()

def main():
    start_commonsys_intf_checker()

if __name__ == '__main__':
    main()
