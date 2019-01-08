import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Hashtable;
import java.util.Iterator;

public class TomcatParser {

	
	private class Request {
		private String id;
		private String timestamp;
		private String st;
		private String et;
		private String category;
		public Request(String id, String timestamp, String st, String et,
				String category) {
			super();
			this.id = id;
			this.timestamp = timestamp;
			this.st = st;
			this.et = et;
			this.category = category;
		}
		public String getId() {
			return id;
		}
		public void setId(String id) {
			this.id = id;
		}
		public String getTimestamp() {
			return timestamp;
		}
		public void setTimestamp(String timestamp) {
			this.timestamp = timestamp;
		}
		public String getSt() {
			return st;
		}
		public void setSt(String st) {
			this.st = st;
		}
		public String getEt() {
			return et;
		}
		public void setEt(String et) {
			this.et = et;
		}
		public String getCategory() {
			return category;
		}
		public void setCategory(String category) {
			this.category = category;
		}
		
	}
	
	private String accessfile;
	private String servletsfile;
	private String output;
	private String dbFile;
	Hashtable<String, Request> accesstable;
	Hashtable<String, Request> accesscollisiontable;
	
	public TomcatParser(String accessfile, String servletsfile, String output, String db) {
		super();
		this.accessfile = accessfile;
		this.servletsfile = servletsfile;
		this.output = output;
		this.dbFile = db;
	}
	
	//Parse Access File to get the hashtable
	public void parseAccess()
	{
		int counter = 0;
		accesstable = new Hashtable<String, Request>();
		accesscollisiontable = new Hashtable<String, Request>();
		//test category
		//Hashtable<String, Integer> cat = new Hashtable<String, Integer>(); 
		BufferedReader reader;
		int len;
		String id = "";
		String timestamp = "";
		String st = "";
		String et = "";
		String category = "";
		//Integer value;
		try {
			reader = new BufferedReader(new FileReader(accessfile));
			String row;
			try {
				while ((row = reader.readLine()) != null) {
					//split the row to get each record
					String[] strs = row.trim().split("\\s+");
					len = strs.length;
					try{
						id = strs[4].split("urlID=")[1];
						timestamp = strs[len-1].split("=")[1]; 
						st = strs[8].split("=")[1];
						et = strs[9].split("=")[1];
						String[] strcat = strs[4].split("\\?")[0].split("\\.");
						len = strcat.length;
						category = strcat[len-1];
						/**test category
						value = cat.get(category);
						if(value == null) {
							cat.put(category, 1);
						}else{
							cat.put(category, value+1);
						}
						*/
						Request req = new Request(id, timestamp, st, et, category);
						if(accesstable.containsKey(id)){
							System.out.println("Existed id: " + id);
							Request existedreq = accesstable.get(id);
							System.out.println("\t" + req.getCategory() + " " + req.getId() + " " + req.getTimestamp() + " " + req.getSt() + " " + req.getEt());
							System.out.println("\t" + existedreq.getCategory() + " " + existedreq.getId() + " " + existedreq.getTimestamp() + " " + existedreq.getSt() + " " + existedreq.getEt());
							//check st
							if(!req.getCategory().equals(existedreq.getCategory())) {
								if(accesscollisiontable.contains(id)){
									System.out.println("Still collision");
								}else{
									accesscollisiontable.put(id, req);
								}	
							}else {
								System.out.println("Same Rqeust");
							}
						}else {
							accesstable.put(id, req);
						}
					}catch (ArrayIndexOutOfBoundsException ae){
						System.out.println("No UID" + row);
					}
					counter++;
				}
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println("# of total requests: " + counter);
		
	}
	
	//Parse Serverlet File
	public void parseServerlets()
	{
		
		BufferedReader reader;
		int len;
		String id = "";
		int db = 0;
		BufferedWriter out;
		BufferedWriter queueout;
		String[] data;
		
		String category;
		try {
			reader = new BufferedReader(new FileReader(servletsfile));
			out = new BufferedWriter(new FileWriter(output));
			queueout = new BufferedWriter(new FileWriter(dbFile, true));
			StringBuffer quesb = new StringBuffer();
			StringBuffer dbsb = new StringBuffer();
			String row;
			try {
				while ((row = reader.readLine()) != null) {
					String[] strs = row.trim().split("\\s+");
                                        System.out.println(row);
                                        System.out.println(strs[5]);
					len = strs.length;
					id = strs[5].split("urlID=")[1];
					db = (len-3)/3;
					if(accesstable.containsKey(id)){
						
						Request request = accesstable.get(id);
						//No collision
						if(!accesscollisiontable.contains(id)){
							if(request != null) {
								data = process(db, strs, request);
								dbsb.append(data[0]);
								//don't include requestID
								//need to guard data from not having any commas because of no database
								//if(data != null && !data.isEmpty()){
								//	String[] dataArr = data.split(",", 2);
								//	quesb.append(dataArr[1]);
								//}
								quesb.append(data[1]);
							}
						//Collision, then compare category
						}else{
							Request existedreq = accesscollisiontable.get(id);
							if(request != null && existedreq != null) {
								String[] strcat = strs[5].split("\\?")[0].split("\\.");
								len = strcat.length;
								category = strcat[len-1];
								if(category.equals(request.getCategory())) {
									data = process(db, strs, request);
									dbsb.append(data[0]);
									//if(data != null && !data.isEmpty()){
									//	String[] dataArr = data.split(",", 2);
									//	quesb.append(dataArr[1]);
									//}
									quesb.append(data[1]);
								}else if(category.equals(existedreq.getCategory())){
									data = process(db, strs, existedreq);
									dbsb.append(data[0]);
									//if(data != null && !data.isEmpty()){	
									//	String[] dataArr = data.split(",", 2);
									//	quesb.append(dataArr[1]);
									//}
									quesb.append(data[1]);
								}
							}
						}
							
					}else{
						System.out.println("Error: when looking for id: "+ id);
					}
					
				}
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			//out.write(sb.toString());
			out.write(dbsb.toString());
			out.close();
			queueout.write(quesb.toString());
			queueout.close();
			
		}catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	
	}
	
	public String[] process(int db, String[] strs, Request request)
	{
		int i;
		int j;
		Long[] dbst;
		Long[] dbet;
		long rt;
		long exet;
	
		double rt1;
		double exet1;
		
		double timestamp;
		double stimestamp;
		double etimestamp;
		dbst = new Long[db];
		dbet = new Long[db];
		StringBuffer data = new StringBuffer();
		StringBuffer data2 = new StringBuffer();
		for(i = 0; i < db; i++) {
			j = 3 + 3*i;
			//j is dbst
			dbst[i] = (Long.parseLong(strs[j].split("=")[1]));
			//j+1 is dbet
			dbet[i] = (Long.parseLong(strs[j+1].split("=")[1]));
			rt = dbet[i] - dbst[i];
			exet = dbst[i] - Long.parseLong(request.st);
			//convert nanoseconds to ms
			rt1 = (double)rt/(double)1000000;
			exet1 = (double)exet/(double)1000000;
			timestamp = Double.parseDouble(request.getTimestamp());
			stimestamp = (timestamp + exet1)/(double)1000;
			etimestamp = (timestamp + exet1 + rt1)/(double)1000;
			data.append(String.format("%s,%.3f,%.3f,%s,%.3f\n",request.id, stimestamp, etimestamp, request.category, rt1));
			data2.append(String.format("%.3f,%.3f,%s,%.3f\n",stimestamp, etimestamp, request.category, rt1));
		}
		String[] dataArr = new String[2];
		dataArr[0] = data.toString();
		dataArr[1] = data2.toString();
		return dataArr;
	}
	public void parse(){
		System.out.println("Start Reading Access File: " + accessfile);
		parseAccess();
		System.out.println("Start Processing Access File: " + servletsfile);
		parseServerlets();
		System.out.println("Done with: " + output);
	}
	
	private static String getOutputName(String accessFileName){
	    String[] fileNameParts = accessFileName.split("-");
	    return fileNameParts[0] + "_" + fileNameParts[1] + "_mscope_request.csv";
	
	}
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub

	
		if (args.length!= 3) {

			System.out.println();
			System.out.println("Usage: ");
			System.out.println();
			System.out.println(" java TomcatParser");
			System.out.println(" [TOMCAT_access.log]");
			System.out.println(" [TOMCAT_servlets]");
			System.out.println(" [QueueLength filename]");
			System.out.println();

		} else {
			String access = args[0];
		    String serverlet  = args[1];
		    String output  = getOutputName(access);
		    String db  = args[2];
			TomcatParser tp = new TomcatParser(access, serverlet, output, db);
			tp.parse();

		}
		
		
		
		
	}

	

}
