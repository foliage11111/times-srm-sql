CREATE OR REPLACE PACKAGE BODY ENG_ECN_APPROVERS_PKG as
/* $Header: ENGAPPRB.pls 120.1 2006/03/27 06:53:58 sdarbha noship $ */


PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Approval_List_Id                     NUMBER,
                     X_Employee_Id                          NUMBER,
                     X_Sequence1                            NUMBER,
                     X_Sequence2                            NUMBER DEFAULT NULL,
                     X_Description                          VARCHAR2 DEFAULT NULL,
                     X_Disable_Date                         DATE DEFAULT NULL,
                     X_Attribute_Category                   VARCHAR2 DEFAULT NULL,
                     X_Attribute1                           VARCHAR2 DEFAULT NULL,
                     X_Attribute2                           VARCHAR2 DEFAULT NULL,
                     X_Attribute3                           VARCHAR2 DEFAULT NULL,
                     X_Attribute4                           VARCHAR2 DEFAULT NULL,
                     X_Attribute5                           VARCHAR2 DEFAULT NULL,
                     X_Attribute6                           VARCHAR2 DEFAULT NULL,
                     X_Attribute7                           VARCHAR2 DEFAULT NULL,
                     X_Attribute8                           VARCHAR2 DEFAULT NULL,
                     X_Attribute9                           VARCHAR2 DEFAULT NULL,
                     X_Attribute10                          VARCHAR2 DEFAULT NULL,
                     X_Attribute11                          VARCHAR2 DEFAULT NULL,
                     X_Attribute12                          VARCHAR2 DEFAULT NULL,
                     X_Attribute13                          VARCHAR2 DEFAULT NULL,
                     X_Attribute14                          VARCHAR2 DEFAULT NULL,
                     X_Attribute15                          VARCHAR2 DEFAULT NULL,
                     X_Creation_Date                          DATE,
                     X_Created_By                             NUMBER,
                     X_Last_Update_Login                      NUMBER DEFAULT NULL,
                     X_Last_Update_Date                       DATE,
                     X_Last_Updated_By                        NUMBER
                     ) IS
  CURSOR C IS SELECT rowid FROM eng_ecn_approvers
             WHERE approval_list_id = X_Approval_List_Id;
             x number;
BEGIN
  begin
    select 1 into x from eng_ecn_approvers where approval_list_id=X_Approval_List_Id and employee_id=X_Employee_Id;
    exception when no_data_found then
  INSERT INTO eng_ecn_approvers
         (
          approval_list_id,
          employee_id,
          sequence1,
          sequence2,
          description,
          disable_date,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          creation_date,
          created_by,
          last_update_login,
          last_update_date,
          last_updated_by
          )
  VALUES (
          X_Approval_List_Id,
          X_Employee_Id,
          X_Sequence1,
          X_Sequence2,
          X_Description,
          X_Disable_Date,
          X_Attribute_Category,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Attribute6,
          X_Attribute7,
          X_Attribute8,
          X_Attribute9,
          X_Attribute10,
          X_Attribute11,
          X_Attribute12,
          X_Attribute13,
          X_Attribute14,
          X_Attribute15,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_Last_Update_Date,
          X_Last_Updated_By
         );
         end;
  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;

  wf_local_synch.propagate_user_role(
      p_user_orig_system     => 'PER',
      p_user_orig_system_id  => x_employee_Id,
      p_role_orig_system     => 'ENG_LIST',
      p_role_orig_system_id  => x_approval_List_Id,
      p_start_date           => null,
      p_expiration_date      => X_Disable_Date,--);
      p_overwrite            => TRUE); -- Bug 3817690

END Insert_Row;


PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Approval_List_Id                      NUMBER,
                   X_Employee_Id                           NUMBER,
                   X_Sequence1                             NUMBER,
                   X_Sequence2                             NUMBER DEFAULT NULL,
                   X_Description                           VARCHAR2 DEFAULT NULL ,
                   X_Disable_Date                          DATE DEFAULT NULL,
                   X_Attribute_Category                    VARCHAR2 DEFAULT NULL ,
                   X_Attribute1                            VARCHAR2 DEFAULT NULL ,
                   X_Attribute2                            VARCHAR2 DEFAULT NULL ,
                   X_Attribute3                            VARCHAR2 DEFAULT NULL ,
                   X_Attribute4                            VARCHAR2 DEFAULT NULL ,
                   X_Attribute5                            VARCHAR2 DEFAULT NULL ,
                   X_Attribute6                            VARCHAR2 DEFAULT NULL ,
                   X_Attribute7                            VARCHAR2 DEFAULT NULL ,
                   X_Attribute8                            VARCHAR2 DEFAULT NULL ,
                   X_Attribute9                            VARCHAR2 DEFAULT NULL ,
                   X_Attribute10                           VARCHAR2 DEFAULT NULL ,
                   X_Attribute11                           VARCHAR2 DEFAULT NULL ,
                   X_Attribute12                           VARCHAR2 DEFAULT NULL ,
                   X_Attribute13                           VARCHAR2 DEFAULT NULL ,
                   X_Attribute14                           VARCHAR2 DEFAULT NULL ,
                   X_Attribute15                           VARCHAR2 DEFAULT NULL

) IS
  CURSOR C IS
      SELECT *
      FROM   eng_ecn_approvers
      WHERE  rowid = X_Rowid
      FOR UPDATE of Approval_List_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.approval_list_id = X_Approval_List_Id)
           OR (    (Recinfo.approval_list_id IS NULL)
               AND (X_Approval_List_Id IS NULL)))
      AND (   (Recinfo.employee_id = X_Employee_Id)
           OR (    (Recinfo.employee_id IS NULL)
               AND (X_Employee_Id IS NULL)))
      AND (   (Recinfo.sequence1 = X_Sequence1)
           OR (    (Recinfo.sequence1 IS NULL)
               AND (X_Sequence1 IS NULL)))
      AND (   (Recinfo.sequence2 = X_Sequence2)
           OR (    (Recinfo.sequence2 IS NULL)
               AND (X_Sequence2 IS NULL)))
      AND (   (Recinfo.description = X_Description)
           OR (    (Recinfo.description IS NULL)
               AND (X_Description IS NULL)))
      AND (   (Recinfo.disable_date = X_Disable_Date)
           OR (    (Recinfo.disable_date IS NULL)
               AND (X_Disable_Date IS NULL)))
      AND (   (Recinfo.attribute_category = X_Attribute_Category)
           OR (    (Recinfo.attribute_category IS NULL)
               AND (X_Attribute_Category IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_Attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_Attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_Attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_Attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_Attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.attribute11 = X_Attribute11)
           OR (    (Recinfo.attribute11 IS NULL)
               AND (X_Attribute11 IS NULL)))
      AND (   (Recinfo.attribute12 = X_Attribute12)
           OR (    (Recinfo.attribute12 IS NULL)
               AND (X_Attribute12 IS NULL)))
      AND (   (Recinfo.attribute13 = X_Attribute13)
           OR (    (Recinfo.attribute13 IS NULL)
               AND (X_Attribute13 IS NULL)))
      AND (   (Recinfo.attribute14 = X_Attribute14)
           OR (    (Recinfo.attribute14 IS NULL)
               AND (X_Attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 = X_Attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (X_Attribute15 IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Approval_List_Id                    NUMBER,
                     X_Employee_Id                         NUMBER,
                     X_Sequence1                           NUMBER,
                     X_Sequence2                           NUMBER DEFAULT NULL,
                     X_Description                         VARCHAR2 DEFAULT NULL ,
                     X_Disable_Date                        DATE DEFAULT NULL,
                     X_Attribute_Category                  VARCHAR2 DEFAULT NULL ,
                     X_Attribute1                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute2                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute3                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute4                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute5                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute6                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute7                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute8                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute9                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute10                         VARCHAR2 DEFAULT NULL ,
                     X_Attribute11                         VARCHAR2 DEFAULT NULL ,
                     X_Attribute12                         VARCHAR2 DEFAULT NULL ,
                     X_Attribute13                         VARCHAR2 DEFAULT NULL ,
                     X_Attribute14                         VARCHAR2 DEFAULT NULL ,
                     X_Attribute15                         VARCHAR2 DEFAULT NULL ,
                     X_Last_Update_Login                   NUMBER DEFAULT NULL,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER
) IS

 l_old_employee_id	NUMBER; -- Bug 3817690
 X_Disable_Date1 DATE;

BEGIN
  -- Bug 3817690
  -- Fetch the employee id for the row to be updated
  SELECT Employee_Id
  INTO l_old_employee_id
  FROM eng_ecn_approvers
  WHERE rowid = X_rowid;
  
  IF X_Disable_Date IS NOT NULL THEN
    X_Disable_Date1 := X_Disable_Date-1;
  END IF;
  

  UPDATE eng_ecn_approvers
  SET
    approval_list_id                          =    X_Approval_List_Id,
    employee_id                               =    X_Employee_Id,
    sequence1                                 =    X_Sequence1,
    sequence2                                 =    X_Sequence2,
    description                               =    X_Description,
    disable_date                              =    X_Disable_Date1,
    attribute_category                        =    X_Attribute_Category,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    attribute11                               =    X_Attribute11,
    attribute12                               =    X_Attribute12,
    attribute13                               =    X_Attribute13,
    attribute14                               =    X_Attribute14,
    attribute15                               =    X_Attribute15,
    last_update_login                         =    X_Last_Update_Login,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By
  WHERE rowid = X_rowid;
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
  -- Bug 3817690
  -- If the employee itself is being updated, then disable the old employee
  IF (l_old_employee_id <> X_Employee_Id)
  THEN
    wf_local_synch.propagate_user_role(
      p_user_orig_system     => 'PER',
      p_user_orig_system_id  => l_old_employee_id,
      p_role_orig_system     => 'ENG_LIST',
      p_role_orig_system_id  => x_approval_List_Id,
      p_start_date           => null,
      p_expiration_date      => sysdate,
      p_overwrite            => TRUE);
  END IF;

  wf_local_synch.propagate_user_role(
      p_user_orig_system     => 'PER',
      p_user_orig_system_id  => x_employee_Id,
      p_role_orig_system     => 'ENG_LIST',
      p_role_orig_system_id  => x_approval_List_Id,
      p_start_date           => null,
      p_expiration_date      => X_Disable_Date,
      p_overwrite            => TRUE);

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  l_employee_id number;
  l_approval_list_id number;
  l_username varchar2(320);-- adhachol
  l_rolename varchar2(320);-- adhachol
  l_origSystem   varchar2(30);--adhachol
  l_origSystemID number;--adhachol

BEGIN

  select employee_id, approval_list_id
  into  l_employee_id, l_approval_list_id
  from eng_ecn_approvers
  where rowid = X_Rowid ;

  DELETE FROM eng_ecn_approvers
  WHERE  rowid = X_Rowid;
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
/*
-- adhachol adding Bug #3342686
select name into l_rolename
from wf_roles
where orig_system = 'ENG_LIST'
and orig_system_id = l_approval_list_id;

begin

select name into l_username
from wf_roles
where orig_system = 'PER'
and orig_system_id = l_employee_id;
    l_origSystem := 'PER';
    l_origSystemId := l_employee_id;
  exception
    when NO_DATA_FOUND then
       --Check for possible PER
        SELECT user_name, employee_id, 'PER'
        INTO   l_userName, l_origSystemID, l_origSystem
        FROM   FND_USER
        WHERE  USER_ID =l_employee_id;

end;

WF_DIRECTORY.RemoveUserRole(user_name               => l_username,
				role_name           => l_rolename,
				user_orig_system    => l_origSystem,
				user_orig_system_id => l_origSystemId,
				role_orig_system    => 'ENG_LIST',
				role_orig_system_id => l_approval_list_id);
-- adding ends here Bug #3342686
*/

  wf_local_synch.propagate_user_role(
      p_user_orig_system     => 'PER',
      p_user_orig_system_id  => l_employee_id,
      p_role_orig_system     => 'ENG_LIST',
      p_role_orig_system_id  => l_approval_list_id,
      p_start_date           => null,
      p_expiration_date      => sysdate-1,--);
      p_overwrite            => TRUE); -- Bug 3817690
      
  DELETE FROM WF_LOCAL_USER_ROLES WLUR
  WHERE WLUR.USER_ORIG_SYSTEM = 'PER'
    AND WLUR.ROLE_ORIG_SYSTEM = 'ENG_LIST'
    AND WLUR.USER_ORIG_SYSTEM_ID = l_employee_id
    AND WLUR.ROLE_ORIG_SYSTEM_ID = l_approval_list_id;

END Delete_Row;
PROCEDURE Check_Unique(X_Rowid               VARCHAR2,
                       X_Approval_List_Id    NUMBER,
                       X_Sequence1           NUMBER) IS
  DUMMY NUMBER;
BEGIN
  SELECT 1 INTO DUMMY FROM DUAL WHERE NOT EXISTS
    (SELECT 1 FROM ENG_ECN_APPROVERS
       WHERE
         (Approval_List_Id = X_Approval_List_Id)
         AND (Sequence1 = X_Sequence1)
         AND ((X_Rowid is NULL) or (ROWID <> X_Rowid))
    );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('ENG', 'ENG_SEQUENCE_ENTER');
      APP_EXCEPTION.RAISE_EXCEPTION;
END Check_Unique;

END ENG_ECN_APPROVERS_PKG ;
