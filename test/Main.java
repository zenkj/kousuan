import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;

/**
 * @author wisedu
 *
 */
public class Main {
    private static int char2int(char ch) {
        if (ch >= '0' && ch <= '9') return (int)(ch-'0');
        else return (int)(ch-'A'+10);
    }

    private static int hex(String str) {
        int n = str.length();
        int result = 0;
        while (n > 0) {
            n -= 2;
            int h = char2int(str.charAt(n));
            int l = char2int(str.charAt(n+1));
            result = (result<<8) + (h<<4) + l;
        }
        return result;
    }

    /**
     * @param args
     */
    public static void main(String[] args) {
        /*
        System.out.println("press enter to begin load...");
        try {
            System.in.read();
        } catch (IOException e1) {
            e1.printStackTrace();
        }
        */
        String path = "/home/wecloud/openresty/projects/kousuan/data/q/";
        ArrayList<ArrayList<Integer>> lists = new ArrayList<ArrayList<Integer>>();
        for (int i=1; i<=53; i++) {
            ArrayList<Integer> list = new ArrayList<Integer>();
            lists.add(list);
            BufferedReader reader = null;
            try {
                reader = null;
                reader = new BufferedReader(new InputStreamReader((new FileInputStream(path+i+".txt"))));
                String line = null;
                while((line = reader.readLine()) != null) {
                    //list.add(hex(line));
                    list.add(Integer.parseInt(line));
                }
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            } finally {
                if (reader != null) {
                    try {
                        reader.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
        /*
        System.out.println("load finished, press enter to end...");
        try {
            System.in.read();
        } catch (IOException e1) {
            e1.printStackTrace();
        }
        */
    }
}
