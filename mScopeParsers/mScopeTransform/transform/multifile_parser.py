#!/usr/bin/env python

import os
import sys
import csv
import collections as c
import itertools
import re
import json
import datetime
from dateutil.parser import parse
from transform import filename_utils as f


METASCHEMA = ["type", "header_row_num", "time_index", \
    "delimiter", "output_name", "timestamp", "time_adjustment"]

class NoMatchingFilesError(f.FilenameError):
    '''
        Error for invalid filenames

        Attributes:
            arg_in_err -- the offending argument
            msg -- the message to output
    '''
    def __init__(self, message=None):
        begin_base_msg = 'Directory does not contain any filenames conforming to the grammar.\n \
                        Please use either a different directory or rename your files accordingly.\n'
        end_base_msg = 'Filename Grammar: NODE_COMPONENT_MONITOR_RESOURCE_DATE_METADATA.FILE_EXT where METADATA is optional'
        if message is None:
            self.msg = begin_base_msg + end_base_msg
        else:
            self.msg = message

class NoTimestampColumnFoundError(f.FilenameError):
    '''
        No Timestamp Column

        Attributes:
            arg_in_err -- the offending argument
            msg -- the message to output
    '''
    def __init__(self, message=None):
        base_msg = 'No timestamp column identified\n'
        if message is None:
            self.msg = base_msg
        else:
            self.msg = message

class FileProcessingError(f.FilenameError):
    '''

        Attributes:
            arg_in_err -- the offending argument
            msg -- the message to output
    '''
    def __init__(self, message=None):
        base_msg = 'Problem processing file\n'
        if message is None:
            self.msg = base_msg
        else:
            self.msg = message

def check_file_defn_schema(schema_token_list):
    '''
        checks whether the file contains the "correct" metadata for creating a valid 
        parser specification
    '''
    verify_dict = {_token:0 for _token in METASCHEMA}

    for _token in schema_token_list:
        if _token in verify_dict:
            verify_dict[_token]=1

    return sum(verify_dict.values()) == len(verify_dict)
        

def load_file_defn(_file_spec_path):
    '''
        loads either a default dict or a JSON file at given path into file definition
        schema
    '''
    filename_ext = f.parse_file_ext(_file_spec_path)
    if 'json' not in filename_ext:
        raise FileProcessingError('File spec is not a JSON document.\n')
    
    with open(_file_spec_path) as data_file:
        file_spec = json.load(data_file)
        print(file_spec)
        if check_file_defn_schema(file_spec.keys()):
            return file_spec
        else:
            raise FileProcessingError('File spec does conform to schema.\n')

def clean(_str_to_clean):
    '''
        replacements
        (# => '')
        ([ => '')
        (]: => _)
        (%:pct)
    '''
    clean_line = re.sub(r'[:\]]','_',re.sub(r'%','_PCT',re.sub(r'[#\[]','',_str_to_clean)))
    
    return clean_line.strip()

def merge_headers(_hdr_list):
    #assert length of header list > 1
    items = itertools.chain(*_hdr_list)
    
    unique_items = sorted(list(set(items)))
    TIMESTAMP_KEY_VAL = 'transform_timestamp'
    
    unique_items.insert(0, TIMESTAMP_KEY_VAL)

    return unique_items

def get_timestamp_key(file_defn):

    key_attribs = file_defn['timestamp'].split('_')

    return key_attribs

def transform_time(*time_date):

    def adjust_datetime(_time_adjustment, *date_time):

        _time, _date = date_time
        #change datetime string into epoch timestamp
        #should try catch here for a missing date part
        epoch_time = datetime.datetime(1970, 1, 1)
        date_str = str(_date) + " " + str(_time) + " " + _time_adjustment
        datetime_obj = parse(date_str)
    
        utc_naive  = datetime_obj.replace(tzinfo=None) - datetime_obj.utcoffset()

        _timestamp = (utc_naive -  epoch_time).total_seconds()
    
        return _timestamp

    def adjust_epoch(_time_adjustment, *_time):
        epoch_time = _time[0]
        new_time = datetime.datetime.fromtimestamp(float(epoch_time)) - datetime.timedelta(hours=int(_time_adjustment))
        return new_time.timestamp()
    
    if not time_date:
        raise NoTimestampColumnFoundError
    
    #just timestamp
    if len(time_date) == 1:
        return adjust_epoch
    else:
        return adjust_datetime

def valid_filename_ext(filename_ext_str):
    valid_filename_extensions = {'csv','data','log'}
    return True if filename_ext_str in valid_filename_extensions else False

def build_file_map(dir_to_proc, file_defn):

    file_dict = {}

    for filename in os.listdir(dir_to_proc):

        filename_ext = f.parse_file_ext(filename)
        filename_parser = f.parse_filename(filename)

        if filename_parser:
            monitor_type = filename_parser(f.MONITOR_PART)

            if monitor_type in file_defn['type'] and valid_filename_ext(filename_ext):
                file_path_key = str(dir_to_proc+'/'+filename)
                file_dict[file_path_key] = filename_parser

    if file_dict:
        return file_dict
    else:
        raise NoMatchingFilesError
    
def get_data_from_file(_row_ptr, file_defn, cleaned_header):
    '''
        _row_ptr : pointer to a row of data needing to be processed
        file_defn : dict of params needed for processing the file
        cleaned_header : iterable containing header elements from the file
    '''
    attribs_for_key = get_timestamp_key(file_defn)
    
    transform_time_fn = transform_time(*attribs_for_key)

    time_adj = file_defn['time_adjustment']
    
    data_by_time_key={}
    
    #assert len(headers) == len(row)
    try:
        DataRecord = c.namedtuple('DataRecord', cleaned_header)
    except (ValueError, TypeError):
        raise FileProcessingError
    else:
        for _row in _row_ptr:
            try:
                row = DataRecord._make(_row)
            except (ValueError, TypeError):
                #log
                print('skipping row: {0}'.format(row))
                #continue
            else:
                key_values = [getattr(row, key_attrib) for key_attrib in attribs_for_key]
                key_value = transform_time_fn(time_adj, *key_values)
                data_by_time_key.setdefault(key_value,{}).update(row._asdict())
    
    return data_by_time_key

def get_header_elements(_row_ptr, file_defn, node_name):

    prefix_str = str(node_name) + '_' if node_name else ''

    #skip up to the row specified for the header
    for _ in range(file_defn['header_row_num']):
        header_line = next(_row_ptr)

    _time_index = file_defn['time_index']
    
    header_list = []
    for i,label in enumerate(header_line):
        clean_label = clean(label)
        if i > _time_index:
            clean_label = prefix_str+clean_label
        header_list.append(clean_label)
    
    return header_list

def select_specification():
    '''
        picks the specification among an iterable number that is "best" for the file being
        processed
        
        pseudo code:
        open the file; get the line associated with the header
        check if delimiter specified is present
        check if using the delimiter and the specified timestamp column that 'time'
        or some other string exists
    '''
    
    pass


def process_files(dir_to_proc, file_defn):
    '''
        processes the files in the provided directory using the provided file definition
        
        returns list of headers collected across the files and the rows of data keyed by
        transformed timestamp with corresponding label,value pairs as a dict
    '''

    file_parser_map = build_file_map(dir_to_proc, file_defn)

    output_rows = {}
    collected_headers = []

    for _file in file_parser_map:

        filename_parser = file_parser_map[_file]
        node_name = filename_parser(f.NODE_PART)

        with open(_file, 'r') as _f:

            _delimiter = file_defn['delimiter']
            reader_obj = csv.reader(_f, delimiter=_delimiter)
            
            cleaned_header = get_header_elements(reader_obj, file_defn, node_name)
            
            try: 
                parsed_rows = get_data_from_file(reader_obj, file_defn, cleaned_header)
            except FileProcessingError as e:
                print(e.msg)
                print('Skipping file: {0}'.format(_file))
            else:            
                collected_headers.append(cleaned_header)
                for row_key_val in parsed_rows:
                    output_rows.setdefault(row_key_val,{}).update(parsed_rows[row_key_val])

    return collected_headers, output_rows

def main(dir_to_proc, target_dir, file_defn):

    try:
        headers, output_rows = process_files(dir_to_proc, file_defn)
    except NoMatchingFilesError as e:
        print(e.msg)
    except NoTimestampColumnFoundError as e:
        print(e.msg)
    else:
        time_order = sorted(output_rows.keys())
        
        merged_headers = merge_headers(headers)
        
        row_key = merged_headers[0]

        output_file = target_dir+'/'+file_defn['output_name']
        #extrasaction='ignore'
        with open(output_file, 'w',newline='') as _f:
            writer = csv.DictWriter(_f,  delimiter="|", fieldnames=merged_headers)
            writer.writeheader()
            for transformed_time in time_order:
                collect_dict = {k:v for k,v in output_rows[transformed_time].items()}
                collect_dict[row_key] = transformed_time
                writer.writerow(collect_dict)
        print("Done!")


if __name__ == "__main__":

    if len(sys.argv) == 4:
        directory_to_process = sys.argv[1]
        target_directory = sys.argv[2]
        file_defn_path = sys.argv[3]
        try:
            file_definition = load_file_defn(file_defn_path)
        except FileProcessingError as e:
            print(e.msg)
            print('Please try a different file specification.\n')
        else:
            main(directory_to_process, target_directory, file_definition)
    else:
        print('Wrong number of arguments\n');
        print('Usage: multifile_parser.py directory_to_process target file_definition')
        sys.exit()
