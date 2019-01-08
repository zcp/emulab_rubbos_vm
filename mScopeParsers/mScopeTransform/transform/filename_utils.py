NODE_PART = 0
COMPONENT_PART = 1
MONITOR_PART = 2
RESOURCE_PART = 3
DATE_PART = 4
METADATA_PART = 5
TO_TOKEN = "_TO_"

class FilenameError(Exception):
    pass

class InvalidFilenameError(FilenameError):
    '''
        Error for invalid filenames

        Attributes:
            arg_in_err -- the offending argument
            msg -- the message to output
    '''
    def __init__(self, arg_in_err, message=None):
        begin_base_msg = 'Filename does not conform to filename grammar\n'
        end_base_msg = 'Filename Grammar: NODE_COMPONENT_MONITOR_RESOURCE_DATE_METADATA(optional).FILE_EXT\n'
        self.arg = arg_in_err
        if message is None:
            self.msg = begin_base_msg + end_base_msg
        else:
            self.msg = message + ': ' +  self.arg + '\n' + end_base_msg

def _valid_node(_str_token):
    return True if 'node' in _str_token else False

def _valid_component(_str_token):
    component_set = {'apache','http','tomcat','cjdbc','mysql','nginx'}
    for core_component in component_set:
        if core_component in _str_token.lower():
            return True
    return False

def _valid_date(_str_token):
    return True

def _valid_resource(_str_token):
    acceptable_set = {'cpu','disk','dsk','tab','all','net','io','mem','memory','dst','downstream','pit','pointintime','service_time'}
    return _str_token.lower() in acceptable_set

def _valid_monitor(_str_token):
    acceptable_set = {'coll','collectl','col','sar','iostat','mscope','elbalens','milliscope','mscope_event','mscope_resource'}
    return _str_token.lower() in acceptable_set

def _check_regular_filename_tokens(_filename_tokens):
    '''
        regularized filename format:
        NODE_COMPONENT_MONITOR_RESOURCE_DATE(_METADATA).FILE_EXT
    '''
    num_tokens = len(_filename_tokens)

    if num_tokens < 5:
        raise InvalidFilenameError(str(num_tokens), 'Invalid number of tokens. Must have at least 5; this has length')

    invalid_parts = []
    if not _valid_node(_filename_tokens[NODE_PART]):
        invalid_parts.append('NODE')
    if not _valid_component(_filename_tokens[COMPONENT_PART]):
        invalid_parts.append('COMPONENT')
    if not _valid_monitor(_filename_tokens[MONITOR_PART]):
        invalid_parts.append('MONITOR')
    if not _valid_resource(_filename_tokens[RESOURCE_PART]):
        invalid_parts.append('RESOURCE')
    if not _valid_date(_filename_tokens[DATE_PART]):
        invalid_parts.append('DATE')

    if invalid_parts:
        raise InvalidFilenameError(' '.join(invalid_parts), 'invalid domain')

    return True

def _check_filename_tokens(_filename_tokens):
    '''
        regularized filename format:
        NODE_COMPONENT_MONITOR_RESOURCE_DATE(_METADATA).FILE_EXT
    '''
    num_tokens = len(_filename_tokens)

    if num_tokens < 5:
        raise InvalidFilenameError(str(num_tokens), 'Invalid number of tokens. Must have at least 5; this has length')

    invalid_parts = []
    if not _valid_node(_filename_tokens[NODE_PART]):
        invalid_parts.append('NODE')
    if not _valid_component(_filename_tokens[COMPONENT_PART]):
        invalid_parts.append('COMPONENT')
    if not _valid_monitor(_filename_tokens[MONITOR_PART]):
        invalid_parts.append('MONITOR')
    if not _valid_resource(_filename_tokens[RESOURCE_PART]):
        invalid_parts.append('RESOURCE')
    if not _valid_date(_filename_tokens[DATE_PART]):
        invalid_parts.append('DATE')
    
    if invalid_parts:
        raise InvalidFilenameError(' '.join(invalid_parts), 'invalid domain')
    
    def get(_part):
        '''
            returns the portion of the filename associated with token
        '''
        return _filename_tokens[_part]
    
    return get

def _parse_name(_filename, _posn):
    filename = _filename.split('.')
    return filename[_posn]

def _tokenize(_str, _delim='_'):
    return _str.split(_delim)

def parse_file_ext(_filename_str):
    return _parse_name(_filename_str,1)


def tokenize_name(_filename):

    _filename_tokens = _tokenize(_filename)
    
    return _check_filename_tokens(_filename_tokens)


def parse_filename_refactor(_filename_str):
    '''
        refactor of original
    '''
    filename_primary_part = _parse_name(_filename_str, 0)

    try:
        return tokenize_name(filename_primary_part)
    except InvalidFilenameError as e:
        print('{0} is not valid'.format(_filename_str))
        print(e.msg)


def parse_filename(_filename_str):
    '''
        original
    '''

    filename_primary_part = _parse_name(_filename_str, 0)

    if TO_TOKEN in filename_primary_part:
        filename_parts = _tokenize(filename_primary_part, TO_TOKEN)
        filename_primary_part = filename_parts[0]

    filename_tokens = _tokenize(filename_primary_part)

    def get(_part):
        '''
            returns the portion of the filename associated with token
        '''
        return filename_tokens[_part]

    try:
        _check_regular_filename_tokens(filename_tokens)
        return get
    except InvalidFilenameError as e:
        print('{0} is not valid'.format(_filename_str))
        print(e.msg)
        return None

def parse_file_name(_filename_str):
    '''
        new function.. parses longer filenames and combines the two substrings
        on the opposite sides of the TO token
    '''

    filename_primary_part = _parse_name(_filename_str, 0)
    
    def get(_part):
        '''
            returns the portion of the filename associated with token
        '''
        return filename_tokens[_part]
    
    if TO_TOKEN in _filename_str:
        filename_parts = _tokenize(filename_primary_part, TO_TOKEN)
        
        filename_primary_part = filename_parts[0]
        
        filename_tokens_second = _tokenize(filename_parts[1])
        
        def get(_part):
            '''
                returns the portion of the filename associated with token
            '''
            return filename_tokens[_part]+TO_TOKEN+filename_tokens_second[_part]
        
    filename_tokens = _tokenize(filename_primary_part)
    
    try:
        _check_regular_filename_tokens(filename_tokens)
        return get
    except InvalidFilenameError as e:
        print('{0} is not valid'.format(_filename_str))
        print(e.msg)
        return None