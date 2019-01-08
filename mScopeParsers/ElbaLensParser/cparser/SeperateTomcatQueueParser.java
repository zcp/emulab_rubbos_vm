import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import com.google.common.base.Charsets;
import com.google.common.hash.BloomFilter;
import com.google.common.hash.Funnels;

public class SeperateTomcatQueueParser {

	private String dir;
	private int ntomcat;
	private final static int EI = 10000000;
	private final static double FPP = 0.0000001;
	BloomFilter<CharSequence>[] tomcats;
	
	StringBuffer[] sb;
	private final static String OUTPUT = "HTTPD_access_TOMCAT";
	
	public SeperateTomcatQueueParser(String dir, int ntomcat) {
		super();
		int i;
		this.dir = dir;	
		this.sb = new StringBuffer[ntomcat];
		this.tomcats = new BloomFilter[ntomcat];
		this.ntomcat = ntomcat;
		for(i = 0; i < ntomcat; i++){
			sb[i] = new StringBuffer();
			this.tomcats[i] = BloomFilter.create(Funnels.stringFunnel(Charsets.UTF_8), EI, FPP); 
		}
		
	}

	// Parse Access File to get the hashtable
	public void parseTomcatAccess(String tomcataccessfile, BloomFilter<CharSequence> tomcat) {
		BufferedReader reader;
		String id = "";
		int counter = 0;
		// Integer value;
		try {
			reader = new BufferedReader(new FileReader(dir+"//"+tomcataccessfile));
			String row;
			try {
				while ((row = reader.readLine()) != null) {
					// split the row to get each record
					String[] strs = row.trim().split("\\s+");
					try {
						id = strs[4].split("urlID=")[1];
						counter++;
						tomcat.put(id);
					} catch (ArrayIndexOutOfBoundsException ae) {
						System.out.println("No UID" + row);
					}	
				}
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println(tomcataccessfile + " has " + counter + " records");
	}

	// Parse Access File to get the hashtable
	public void parseApacheAccess(String apacheaccessfile) {
		BufferedReader reader;
		int len;
		String id = "";
		// Integer value;
		int[] count = new int[ntomcat+1];
		
		int countjpg = 0;
		int i;
		String result = "";
		boolean iscontained = false;
		try {
			reader = new BufferedReader(new FileReader(dir+"//"+apacheaccessfile));
			String row;
			try {
				while ((row = reader.readLine()) != null) {
					// split the row to get each record
					String[] strs = row.trim().split("\\s+");
					len = strs.length;
					if(strs[6].contains("jpg")){
						countjpg ++;
					}
					try {
						id = strs[6].split("urlID=")[1];
						iscontained = false;
						for(i = 0; i < ntomcat; i++){
							if(tomcats[i].mightContain(id)){
								sb[i].append(row+"\r\n");
								count[i]++;
								iscontained = true;
								break;
							}
						}
						if(iscontained == false){
							count[ntomcat]++;
						}
						
					} catch (ArrayIndexOutOfBoundsException ae) {
						System.out.println("No UID:" + row);
					}
				}
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		for(i = 0; i <= ntomcat; i++){
			result = result + count[i] + " "; 
		}
		result = result + "\t" + countjpg;
		System.out.println(result);
	}
	

	public void parse() {
		int i = 0;
		int j = 0;
		File[] files;
		String filename;
		File directory = new File(dir);
		files = directory.listFiles();
		BufferedWriter out;
		for(i = 0; i <files.length; i++){
			filename = files[i].getName();
			if(filename.contains("TOMCAT") && filename.contains("access"))
			{
				for(j = 0; j < ntomcat; j++){
					if((j+1) == Integer.parseInt(filename.substring(6, 7))){
						//System.out.println(filename + " " + j);
						parseTomcatAccess(filename, tomcats[j]);
						break;
					}
				}
			}
		}
		System.out.println("All the Tomcat access log files are loaded");
		for(i = 0; i <files.length; i++){
			filename = files[i].getName();
			if(filename.startsWith("HTTPD") && filename.endsWith("access.log"))
			{
				parseApacheAccess(filename);
				System.out.println("Done with " + filename);
			}
		}
		for(i = 0; i < ntomcat; i++){
			try {
				out = new BufferedWriter(new FileWriter(dir+"//"+OUTPUT + i + ".log", true));
				out.write(sb[i].toString());
				out.close();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		
		if (args.length!= 2) {

			System.out.println();
			System.out.println("Usage: ");
			System.out.println();
			System.out.println(" java SeperateTomcatQueueParser");
			System.out.println(" Directory");
			System.out.println(" number of tomcat");
			System.out.println();

		} else {
			String dir = args[0];
		    String ntomcat  = args[1];
		    SeperateTomcatQueueParser stp = new SeperateTomcatQueueParser(dir, Integer.parseInt(ntomcat));
			stp.parse();

		}
		
		/**
		String dir = "D:\\tmp\\121\\22500_10MBcache_request_t1nomillbottleneck_t2millibottleneck_getendpoint_debug_1\\22500";
	    SeperateTomcatQueueParser stp = new SeperateTomcatQueueParser(dir, 2);
		stp.parse();
		*/
	}

}
