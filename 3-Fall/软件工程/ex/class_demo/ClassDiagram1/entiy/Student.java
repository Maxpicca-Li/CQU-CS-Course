/***********************************************************************
 * Module:  Student.java
 * Author:  Maxpicca
 * Purpose: Defines the Class Student
 ***********************************************************************/

package entiy;

import java.util.*;

/** @pdOid 31a315b6-3692-4b76-bb31-0e66d1506d37 */
public class Student implements Student.Interface1 {
   /** @pdOid bb5b7fd4-2d3c-4419-bcbe-b447447cac34 */
   private Integer sAge;
   /** @pdOid 640a578d-6685-4d2b-9313-fcbe103d5ab4 */
   private Long sMoney = 100000000;
   
   /** @pdOid cd9c0c69-b9a0-4c3d-b2ee-5c158d0601f2 */
   protected void finalize() {
      // TODO: implement
   }
   
   /** @pdOid 88a54323-5f65-400d-a37b-88b292fa6e1d */
   public String sId;
   /** @pdOid 6397e79c-4898-4eb8-8855-7d733a91caf5 */
   public java.lang.String sName;
   
   /** @pdRoleInfo migr=no name=Course assc=association1 mult=0..* */
   public Course[] course;
   
   /** @param cid
    * @pdOid 76d082d7-5a9e-4a24-9fb0-e7158ac43c40 */
   public static Integer selectCourse(int cid) {
      // TODO: implement
      return null;
   }
   
   /** @pdOid 582b7224-4a2a-4edf-97c8-65accf374ae4 */
   public Student() {
      // TODO: implement
   }
   
   /** @param oldStudent
    * @pdOid 71e6fafd-685c-44ab-bc19-7589057c62d2 */
   public Student(Student oldStudent) {
      sId = oldStudent.sId;
      sName = oldStudent.sName;
      sAge = oldStudent.sAge;
      sMoney = oldStudent.sMoney;
   }

   /** @pdOid ea3f5c20-8d24-49be-9984-c3ff43ca63f0 */
   public interface Interface1 {
   }

}