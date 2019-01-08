/*
 * Copyright 2002 Sun Microsystems, Inc. All rights reserved.
 * SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 */

package customer;

import java.io.Serializable;

/**
 * This is a dependent value class.
 *
 * @author	Qingqing Ouyang
 * @version
 * @see        
 * @since
 */
public class SubscriptionType implements Serializable {

    private String type;

    public static final SubscriptionType MAGAZINE 
    = new SubscriptionType("Magazine");

    public static final SubscriptionType JOURNAL 
    = new SubscriptionType("Journal");

    public static final SubscriptionType NEWS_PAPER 
    = new SubscriptionType("News Paper");

    public static final SubscriptionType OTHER 
    = new SubscriptionType("Other");

    private SubscriptionType (String type) {
        this.type = type;
    }

    public String getType() {
        return type;
    }

    public String toString() {
        return type;
    }
}
