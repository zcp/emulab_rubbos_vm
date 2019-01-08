from __future__ import division
import os
import sys
import datetime as dt
import collections as c


def norm_time(input_time):
    hr = int(input_time.split(':')[0])
    mins = int(input_time.split(':')[1])
    sec_parts = input_time.split(':')[2].split('.')
    secs = int(sec_parts[0])
    millis = dt.timedelta(milliseconds=int(sec_parts[1]))
    a_time = dt.datetime(2014,4,14,hr,mins,secs) + millis
    return a_time.timestamp()

def process_filename(_filename):
    parts = _filename.split('-')
    if len(parts) >= 2:
        resource_name = parts[1]
        node_name = parts[3]
        return node_name, resource_name
    else:
        raise Exception

def process_CPU_lines(_file):
    file_dict = {}
    
    for x in _file:
        line_parts = x.split(' ')
        if ":" in x:
            last_idx = len(line_parts) - 1
            normed_time = norm_time(line_parts[0])
            file_dict[normed_time] = 100 - int(line_parts[last_idx])
    
    return file_dict

def process_DISK_lines(_file):
    file_dict = c.defaultdict(list)
    
    for x in _file:
        line_parts = x.split(' ')
        if ":" in x:
            last_idx = len(line_parts) - 1
            normed_time = norm_time(line_parts[0])
            file_dict[normed_time].append(int(line_parts[last_idx]))
    
    max_val_dict = {}
    
    for time, vals in file_dict.items():
        max_val = max(vals)
        max_val_dict[time] = max_val
        
    return  max_val_dict

def process_dir(input_directory, excludes = None):
    file_map = {}

    for filename in os.listdir(input_directory):
        exclude = any(excl in filename for excl in excludes)
        if not filename.startswith('.') and not exclude:
            try:
                node_part, resource_part = process_filename(filename)
                file_map[filename] = (node_part, resource_part)
            except Exception:
                print("Can't process {0}".format(filename))

    return file_map

def output(_dir, _matrix):
    
    stringify = lambda y : '|'.join(map(lambda x: str(x), y))
    
    outfile = _dir+'data_matrix.data'
    outf = open(outfile,'w')
    
    outf.write(stringify(_matrix[0]))
    outf.write('\n')
    
    for row in _matrix[1:]:
        outf.write(stringify(row))
        outf.write('\n')
    outf.close()
    

def get_headers(total_map):
    
    headers = set()
    
    for parsed_vals_map in total_map.values():
        headers.update(parsed_vals_map.keys())
    
    header_list = sorted(list(headers))
    
    header_list.insert(0, 'timestamp')
    
    return header_list

def main(input_directory, output_directory):

    output_map = c.defaultdict(dict)
    
    #create filemap
    #maps filename to positions of timestamps and resources
    file_map = process_dir(input_directory, ['client'])
    
    for file, node_rsrc_tuple in file_map.items():
        
        with open(input_directory+file) as f:
            if 'CPU' in node_rsrc_tuple[1]:
                parsed_dict = process_CPU_lines(f)
            elif 'DISK' in node_rsrc_tuple[1]:
                parsed_dict = process_DISK_lines(f)

            for timestamp, value in parsed_dict.items():
                key = node_rsrc_tuple[0]+"_"+node_rsrc_tuple[1]
                _timestamp = int((timestamp*10)) / 10
                output_map[_timestamp].update({key:value})
    
    output_map = c.OrderedDict(sorted(output_map.items(), key=lambda item_tuple : item_tuple[0]))
    
    headers = get_headers(output_map)
    
    output_matrix = []
    output_matrix.append(headers)
    
    header_map = {header:idx for idx,header in enumerate(headers)}
    
    for timestamp, vals_dict in output_map.items():
        _line = [None] * len(headers)
        _line[0] = timestamp
        for label, magnitude in vals_dict.items():
            _line[header_map[label]] = magnitude
        
        output_matrix.append(_line)
    
    output(output_directory,output_matrix)
    
    print('Done!')
    

if __name__ == "__main__":

    if len(sys.argv) == 3:
        dir_to_process = sys.argv[1]
        target_dir = sys.argv[2]
    elif len(sys.argv) < 3:
        dir_to_process = '/Users/jmkimball/Desktop/process_bin/collectl/'
        target_dir = '/Users/jmkimball/Desktop/'
    else:
        raise Exception('Wrong number of arguments')
    
    dir_to_process = dir_to_process if dir_to_process[-1] == '/' else dir_to_process + '/'
    main(dir_to_process, target_dir)