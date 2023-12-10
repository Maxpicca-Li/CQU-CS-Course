/***********************************************************************
 * Module:  Class4.java
 * Author:  Maxpicca
 * Purpose: Defines the Class Class4
 ***********************************************************************/

package entiy;

import java.util.*;

/** @pdOid fc36b912-6e72-4787-8be8-fdbefacb2cf9 */
public class Class4 {
   /** @pdRoleInfo migr=no name=Class5 assc=association2 coll=java.util.Collection impl=java.util.HashSet mult=0..* type=Aggregation */
   public java.util.Collection<Class5> class5;
   
   
   /** @pdGenerated default getter */
   public java.util.Collection<Class5> getClass5() {
      if (class5 == null)
         class5 = new java.util.HashSet<Class5>();
      return class5;
   }
   
   /** @pdGenerated default iterator getter */
   public java.util.Iterator getIteratorClass5() {
      if (class5 == null)
         class5 = new java.util.HashSet<Class5>();
      return class5.iterator();
   }
   
   /** @pdGenerated default setter
     * @param newClass5 */
   public void setClass5(java.util.Collection<Class5> newClass5) {
      removeAllClass5();
      for (java.util.Iterator iter = newClass5.iterator(); iter.hasNext();)
         addClass5((Class5)iter.next());
   }
   
   /** @pdGenerated default add
     * @param newClass5 */
   public void addClass5(Class5 newClass5) {
      if (newClass5 == null)
         return;
      if (this.class5 == null)
         this.class5 = new java.util.HashSet<Class5>();
      if (!this.class5.contains(newClass5))
         this.class5.add(newClass5);
   }
   
   /** @pdGenerated default remove
     * @param oldClass5 */
   public void removeClass5(Class5 oldClass5) {
      if (oldClass5 == null)
         return;
      if (this.class5 != null)
         if (this.class5.contains(oldClass5))
            this.class5.remove(oldClass5);
   }
   
   /** @pdGenerated default removeAll */
   public void removeAllClass5() {
      if (class5 != null)
         class5.clear();
   }

}