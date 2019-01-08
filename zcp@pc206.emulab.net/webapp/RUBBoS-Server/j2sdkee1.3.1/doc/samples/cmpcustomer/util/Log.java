/*
 * Copyright 2002 Sun Microsystems, Inc. All rights reserved.
 * SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 */

package util;

/**
 *
 * @author	Qingqing Ouyang
 * @version
 * @see        
 * @since
 */
public class Log {
    
    public static void log (String message) {
        System.out.println("LOG: " + message);
    }

    public static void trace (String message) {
        System.out.println("TRACE: " + message);
    }

    public static void error (String message) {
        System.err.println("ERROR: " + message);
    }

}
