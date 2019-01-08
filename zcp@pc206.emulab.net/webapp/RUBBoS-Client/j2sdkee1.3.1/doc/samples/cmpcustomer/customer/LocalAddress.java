/*
 * Copyright 2002 Sun Microsystems, Inc. All rights reserved.
 * SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 */

package customer;

import javax.ejb.EJBLocalObject;

/**
 *
 * @author	Qingqing Ouyang
 */
public interface LocalAddress extends EJBLocalObject{

    public String getAddressID();
    public String getStreet();
    public String getCity();
    public String getZip();
    public String getState();
}
