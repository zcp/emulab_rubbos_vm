import unittest
import mock
import transform.filename_utils as f
import transform.multifile_parser as tform

class TransformerTestCase(unittest.TestCase):
    """Filename parser test cases."""

    def setUp(self):
        """Create simple filenames."""

        #global collectl_filename1

        self.collectl_filename1='node7_MYSQL1_coll_cpu_20170611.data'

        self.collectl_filename2='coll_node7_20161012.cpu'

        self.collectl_filename3='collectl_DISK_CA_Tomcat2_20140414205404.data'
        
        self.collectl_filename4='collectl_DISK_CA_Tomcat2_20140414205404'

        self.header1_str = '#Date Time [CPU:0]User% [CPU:0]Nice% [CPU:0]Sys% [CPU:0]Wait% [CPU:0]Irq% [CPU:0]Soft% [CPU:0]Steal% [CPU:0]Idle% [CPU:0]Totl% [CPU:0]Guest% [CPU:0]GuestN% [CPU:0]Intrpt \
                    [CPU:1]User% [CPU:1]Nice% [CPU:1]Sys% [CPU:1]Wait% [CPU:1]Irq% [CPU:1]Soft% [CPU:1]Steal% [CPU:1]Idle% [CPU:1]Totl% [CPU:1]Guest% [CPU:1]GuestN% [CPU:1]Intrpt'
        
        self.header1_list = ['#Date', 'Time', '[CPU:0]User%', '[CPU:0]Nice%', '[CPU:0]Sys%', '[CPU:0]Wait%', '[CPU:0]Irq%', '[CPU:0]Soft%', '[CPU:0]Steal%', '[CPU:0]Idle%', '[CPU:0]Totl%', '[CPU:0]Guest%', '[CPU:0]GuestN%', '[CPU:0]Intrpt', \
                    '[CPU:1]User%', '[CPU:1]Nice%', '[CPU:1]Sys%', '[CPU:1]Wait%', '[CPU:1]Irq%', '[CPU:1]Soft%', '[CPU:1]Steal%', '[CPU:1]Idle%', '[CPU:1]Totl%', '[CPU:1]Guest%', '[CPU:1]GuestN%', '[CPU:1]Intrpt']

        self.header2_str = '#Date Time [DSK:sdb]Name [DSK:sdb]Reads [DSK:sdb]RMerge [DSK:sdb]RKBytes [DSK:sdb]WaitR [DSK:sdb]Writes [DSK:sdb]WMerge [DSK:sdb]WKBytes [DSK:sdb]WaitW [DSK:sdb]Request [DSK:sdb]QueLen [DSK:sdb]Wait [DSK:sdb]SvcTim [DSK:sdb]Util \
                    [DSK:sda]Name [DSK:sda]Reads [DSK:sda]RMerge [DSK:sda]RKBytes [DSK:sda]WaitR [DSK:sda]Writes [DSK:sda]WMerge [DSK:sda]WKBytes [DSK:sda]WaitW [DSK:sda]Request [DSK:sda]QueLen [DSK:sda]Wait [DSK:sda]SvcTim [DSK:sda]Util'

        self.header2_list = ['#Date', 'Time', '[DSK:sdb]Name', '[DSK:sdb]Reads', '[DSK:sdb]RMerge', '[DSK:sdb]RKBytes', '[DSK:sdb]WaitR', '[DSK:sdb]Writes', \
                        '[DSK:sdb]WMerge', '[DSK:sdb]WKBytes', '[DSK:sdb]WaitW', '[DSK:sdb]Request', '[DSK:sdb]QueLen', '[DSK:sdb]Wait', '[DSK:sdb]SvcTim', '[DSK:sdb]Util', \
                        '[DSK:sda]Name', '[DSK:sda]Reads', '[DSK:sda]RMerge', '[DSK:sda]RKBytes', '[DSK:sda]WaitR', '[DSK:sda]Writes', '[DSK:sda]WMerge', '[DSK:sda]WKBytes', '[DSK:sda]WaitW', '[DSK:sda]Request', '[DSK:sda]QueLen', '[DSK:sda]Wait', '[DSK:sda]SvcTim', '[DSK:sda]Util']

        self.header_data1 = [['#Date', 'Time', '[CPU:0]User%', '[CPU:0]Nice%', '[CPU:0]Sys%', '[CPU:0]Wait%'], 
                            ['20170611', '18:04:12.501', '20', '100', '0', '20']]
                            
        self.file_spec1={"type":"collectl_sample", "header_row_num":1, "time_index": 1,
                                "delimiter":" ", "output_name":"by_node_rsrc_util.csv", 
                                "timestamp":"Time_Date", "time_adjustment":"-0400"}

    def tearDown(self):
        """Teardown."""
        pass

    def test_parse_filename_refactor(self):
        filename_parser = f.parse_filename_refactor(self.collectl_filename1)
        self.assertEqual(filename_parser(f.NODE_PART), 'node7')
        self.assertEqual(filename_parser(f.COMPONENT_PART), 'MYSQL1')
        self.assertEqual(filename_parser(f.MONITOR_PART), 'coll')
        self.assertEqual(filename_parser(f.RESOURCE_PART), 'cpu')
        self.assertEqual(filename_parser(f.DATE_PART), '20170611')

    def test_invalid_token_order(self):
        with self.assertRaises(f.InvalidFilenameError) as cm:
            f.tokenize_name(self.collectl_filename4)    
 
    @mock.patch('transform.filename_utils.tokenize_name')
    def test_parse_invalid_fname(self, mock_check_reg_filename):
        try:
            mock_check_reg_filename.side_effect = f.InvalidFilenameError('Bad filename')
        except f.InvalidFilenameError:
            self.assertIsNone(f.parse_filename_refactor(self.collectl_filename3))

    '''  
        below are the older test cases
        
        def test_split(self):
        s = 'hello world'
        self.assertEqual(s.split(), ['hello', 'world'])
        # check that s.split fails when the separator is not a string
        with self.assertRaises(TypeError):
            s.split(2)
    '''
    
    def test_parse_name(self):
        self.assertEqual(f._parse_name(self.collectl_filename1,0), 'node7_MYSQL1_coll_cpu_20170611')

    def test_parse_filename(self):
        filename_parser = f.parse_filename(self.collectl_filename1)
        self.assertEqual(filename_parser(f.NODE_PART), 'node7')
        self.assertEqual(filename_parser(f.COMPONENT_PART), 'MYSQL1')
        self.assertEqual(filename_parser(f.MONITOR_PART), 'coll')
        self.assertEqual(filename_parser(f.RESOURCE_PART), 'cpu')
        self.assertEqual(filename_parser(f.DATE_PART), '20170611')

    def test_invalid_token_size(self):
        tokens = f._tokenize(self.collectl_filename2)
        with self.assertRaises(f.InvalidFilenameError) as cm:
            f._check_regular_filename_tokens(tokens) 

    def test_invalid_token_order(self):
        tokens = f._tokenize(self.collectl_filename3)
        with self.assertRaises(f.InvalidFilenameError) as cm:
            f._check_regular_filename_tokens(tokens)
    
    @mock.patch('transform.filename_utils._check_regular_filename_tokens')
    def test_parse_invalid_filename(self, mock_check_reg_filename):
        try:
            mock_check_reg_filename.side_effect = f.InvalidFilenameError('None')
        except f.InvalidFilenameError:
            self.assertIsNone(f.parse_filename(self.collectl_filename3))

    # data transformation use cases

    def test_merge_headers(self):
        collected_headers = []
        collected_headers.append(self.header1_list)
        collected_headers.append(self.header2_list)
        self.assertEqual(len(tform.merge_headers(collected_headers)), len(self.header1_list) + len(self.header2_list)-2 + 1)

    def test_time_adjustment(self):
        pass
        #self.assertEqual(tform.adjust_timestamp(1476289785, 2),1476282585)
    
    def test_get_data_from_file(self):
        correct_header = ['Date', 'Time', 'CPU_0_User_PCT', 'CPU_0_Nice_PCT', 'CPU_0_Sys_PCT', 'CPU_0_Wait_PCT']
        correct_dict = {1497218652.501:{'Date':'20170611', 'Time':'18:04:12.501', 'CPU_0_User_PCT':'20', 'CPU_0_Nice_PCT':'100', 'CPU_0_Sys_PCT':'0', 'CPU_0_Wait_PCT':'20'}}
        self.assertEqual(tform.get_data_from_file(iter(self.header_data1[1:]), self.file_spec1, correct_header), correct_dict)

    def test_get_headers(self):
        correct_header = ['Date', 'Time', 'CPU_0_User_PCT', 'CPU_0_Nice_PCT', 'CPU_0_Sys_PCT', 'CPU_0_Wait_PCT']
        self.assertEqual(tform.get_header_elements(iter(self.header_data1), self.file_spec1, None), correct_header)

    
if __name__ == '__main__':
    unittest.main()
