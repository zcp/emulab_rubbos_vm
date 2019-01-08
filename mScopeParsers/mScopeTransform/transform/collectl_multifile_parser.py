#!/usr/bin/env python

import sys
import multifile_parser as mfp

COLLECTL_SPECS = [{"type":"collectl", "header_row_num":16, "time_index": 1,
                                "delimiter":" ", "output_name":"by_node_rsrc_util.csv", 
                                "timestamp":"Time_Date", "time_adjustment":"-0400"},
                   {"type":"collectl", "header_row_num":15, "time_index": 1,
                                "delimiter":" ", "output_name":"by_node_rsrc_util.csv", 
                                "timestamp":"Time_Date", "time_adjustment":"-0400"}]

def main(_dir_to_proc, _target_dir, _file_defn):

    mfp.main(_dir_to_proc, _target_dir, _file_defn)

if __name__ == "__main__":
    #directory_to_process = '/Users/jmkimball/Documents/classes-grad-school/g_fall-2014/elba/jmk-work/src/milliscope/test-data'
    #directory_to_process = '/Users/jmkimball/Desktop/process_bin/local_tao/nocache_70000/20000-RO/coll'
    directory_to_process = '/Users/jmkimball/Desktop/process_bin/local_jmk/2000'
    target_directory = '/Users/jmkimball/Desktop'
    file_definition = COLLECTL_SPECS[0]

    if len(sys.argv) == 3:
        directory_to_process = sys.argv[1]
        target_directory = sys.argv[2]
        file_definition = COLLECTL_SPECS[0]
    elif len(sys.argv) == 4:
        directory_to_process = sys.argv[1]
        target_directory = sys.argv[2]
        file_defn_path = sys.argv[3]        
        try:
            file_definition = mfp.load_file_defn(file_defn_path)
        except mfp.FileProcessingError as e:
            print(e.msg)
            print('Please try a different file specification.\n')
            sys.exit()
    
    if '/' in directory_to_process[-1]:
        directory_to_process = directory_to_process[0:-1]

    main(directory_to_process, target_directory, file_definition)
