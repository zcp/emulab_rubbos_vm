import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.Hashtable;
import java.util.List;


public class PointInTimeParser {

	private String dir;
	static final float INTERVAL = 0.05f;
	static final String FILENAME = "QueueLength-Apache.csv";
	static final String OUTPUT = "Pointintime.csv";
	
	public PointInTimeParser(String dir) {
		super();
		this.dir = dir;
	}

	public void parseApacheCSV() {
		BufferedReader reader;
		
		// Integer value;
		Hashtable<Long, List<Float>> ht = new Hashtable<Long, List<Float>>();
		StringBuffer sb = new StringBuffer();
		long bucket = 0;
		BufferedWriter out;
		List<Float> list = null;
		ArrayList<Long> keys;
		int sum = 0;
		float average = 0.0f;
		int cnt = 0;
		String rounddown = "";
		try {
			reader = new BufferedReader(new FileReader(dir + "//" + FILENAME));
			String row;
			try {
				while ((row = reader.readLine()) != null) {
					// split the row to get each record
					String[] strs = row.trim().split(",");
					//get ST time
					int lasttwo = Integer.parseInt(strs[0].substring(strs[0].length()-2));
					if(lasttwo >=0 && lasttwo <= 49){
						rounddown = strs[0].substring(0, strs[0].length()-2) + "00";
					}else{
						rounddown = strs[0].substring(0, strs[0].length()-2) + "50";
					}
					bucket = (long)(Double.parseDouble(rounddown)*1000);
					list = ht.get(bucket);
					if(list == null){
						list = new ArrayList<Float>();
					}
					list.add(Float.parseFloat(strs[3]));
					ht.put(bucket, list);
					
				}
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		try {
			out = new BufferedWriter(new FileWriter(dir+"//"+OUTPUT, true));
			sb.append("timestamp,pit(ms)\r\n");
			keys = new ArrayList(ht.keySet());
			Collections.sort(keys);
			for(long key: keys){
				sum = 0;
				list = ht.get(key);
				cnt = list.size();
				for(double rt: list){
					sum+=rt;
				}
				average = (float)sum/cnt;
				sb.append(key + "," + average + "\r\n");
			}
			out.write(sb.toString());
			out.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		
		if (args.length!= 1) {

			System.out.println();
			System.out.println("Usage: ");
			System.out.println();
			System.out.println(" java PointInTimeParser");
			System.out.println(" Directory");
			System.out.println();

		} else {
			String dir = args[0];
		    PointInTimeParser analyer = new PointInTimeParser(dir);
		    analyer.parseApacheCSV();

		}
		
		
	}

}
