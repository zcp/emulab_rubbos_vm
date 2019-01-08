#!/usr/bin/env python

import sys
import multifile_parser as mfp

DST_SPECS =[{"type":"mscope", "header_row_num":1, "time_index": 0,
                    "delimiter":"|", "output_name":"by_node_avg_resp_time_timestamp.csv",
                     "timestamp":"timestamp", "time_adjustment":"2"},
            {"type":"mscope", "header_row_num":1, "time_index": 0,
                    "delimiter":",", "output_name":"by_node_avg_resp_time_timestamp.csv",
                     "timestamp":"timestamp", "time_adjustment":"2"} ] 

def main(_dir_to_proc, _target_dir, _file_defn):

    mfp.main(_dir_to_proc, _target_dir, _file_defn)

if __name__ == "__main__":

    if len(sys.argv) == 3:
        directory_to_process = sys.argv[1]
        target_directory = sys.argv[2]
        file_definition = DST_SPECS[0]
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
    else:
        directory_to_process = '/Users/jmkimball/Desktop/process_bin/local_tao/nocache_70000/20000-RO/downstream_time'
        #directory_to_process = '/Users/jmkimball/Desktop/process_bin/local_tao/nocache_70000/20000-RO/dst'
        target_directory = '/Users/jmkimball/Desktop'
        file_definition = DST_SPECS[1]

    if '/' in directory_to_process[-1]:
        directory_to_process = directory_to_process[0:-1]

    main(directory_to_process, target_directory, file_definition)