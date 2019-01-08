/*
 * Copyright 2002 Sun Microsystems, Inc. All rights reserved.
 * SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 */

package customer;

import java.util.ArrayList;
import javax.ejb.EJBLocalObject;

/**
 *
 * @author	Qingqing Ouyang
 */
public interface LocalSubscription extends EJBLocalObject{

    public String getTitle();
    public SubscriptionType getType();
    public ArrayList getCustomerList();
}
