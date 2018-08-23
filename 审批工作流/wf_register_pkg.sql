CREATE OR REPLACE PACKAGE BODY wf_register_pkg IS
  PROCEDURE output(p_msg VARCHAR2) IS
  BEGIN
    fnd_file.PUT_LINE(fnd_file.OUTPUT, p_msg);
  END;
  PROCEDURE db_output(p_msg VARCHAR2) IS
  BEGIN
    /*IF C_DB_DEBUG = 'Y' THEN
    dbms_output.put_line(p_msg);
    END IF;*/
    NULL;
  END;

  PROCEDURE register_by_position IS
    --find all postion
    CURSOR c_position IS
      SELECT paa.organization_id, paa.position_id
        FROM PER_ALL_ASSIGNMENTS_F paa
       WHERE 1 = 1
         AND paa.last_update_date >
             (SELECT last_update_date
                FROM wf_approve_role_update_tl
               WHERE rownum < 2)
         AND paa.position_id IS NOT NULL
         AND EXISTS
       (SELECT 1
                FROM fnd_user fu
               WHERE 1 = 1
                 AND fu.employee_id = paa.person_id
                 AND trunc(SYSDATE) BETWEEN nvl(fu.start_date, SYSDATE - 1) AND
                     nvl(fu.end_date, SYSDATE + 1))
         AND trunc(SYSDATE) BETWEEN
             nvl(paa.effective_start_date, SYSDATE - 1) AND
             nvl(paa.effective_end_date, SYSDATE + 1)
       GROUP BY paa.organization_id, paa.position_id;
    --find all person belong to position
    CURSOR c_person(p_position_id NUMBER, p_org_id NUMBER) IS
      SELECT paa.person_id, paa.effective_end_date
        FROM PER_ALL_ASSIGNMENTS_F paa
       WHERE 1 = 1
         AND paa.position_id = p_position_id
         AND EXISTS
       (SELECT 1
                FROM fnd_user fu
               WHERE 1 = 1
                 AND fu.employee_id = paa.person_id
                 AND trunc(SYSDATE) BETWEEN nvl(fu.start_date, SYSDATE - 1) AND
                     nvl(fu.end_date, SYSDATE + 1))
         AND trunc(SYSDATE) BETWEEN
             nvl(paa.effective_start_date, SYSDATE - 1) AND
             nvl(paa.effective_end_date, SYSDATE + 1)
         AND paa.organization_id = p_org_id;
    --standard position delete, role must delete
    CURSOR c_position_delete IS
      SELECT eeal.rowid
        FROM eng_ecn_approval_lists eeal
       WHERE 1 = 1
         AND eeal.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_POSITION
         AND NOT EXISTS
       (SELECT 1
                FROM HR_ALL_POSITIONS_F paa
               WHERE 1 = 1
                 AND trunc(SYSDATE) BETWEEN
                     nvl(paa.effective_start_date, SYSDATE - 1) AND
                     nvl(paa.effective_end_date, SYSDATE + 1)
                 AND paa.position_id = eeal.attribute2
                 AND paa.organization_id = eeal.attribute3);
    --person need delete
    CURSOR c_person_delete IS
      SELECT eea.rowid
        FROM eng_ecn_approvers eea, eng_ecn_approval_lists eeal
       WHERE 1 = 1
         AND eea.approval_list_id = eeal.approval_list_id
         AND eeal.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_POSITION
         AND NOT EXISTS
       (SELECT 1
                FROM PER_ALL_ASSIGNMENTS_F paa
               WHERE 1 = 1
                 AND trunc(SYSDATE) BETWEEN
                     nvl(paa.effective_start_date, SYSDATE - 1) AND
                     nvl(paa.effective_end_date, SYSDATE + 1)
                 AND paa.position_id = eeal.attribute2
                 AND paa.person_id = eea.employee_id);
    v_position        c_position%ROWTYPE;
    v_person          c_person%ROWTYPE;
    v_position_delete c_position_delete%ROWTYPE;
    v_person_delete   c_person_delete%ROWTYPE;
    v_pos_count       NUMBER := 0;
    v_per_count       NUMBER := 0;
    p_rowid           VARCHAR2(250);
    p_list_id         NUMBER;
    p_seq             NUMBER;
    p_index           NUMBER;
    p_delete_count    NUMBER := 0;
    p_position_name   VARCHAR2(100);
    --p_person_name   varchar2(100);
    p_disabled_date     DATE;
    p_old_disabled_date DATE;
  BEGIN
    output('/*******************************************************************');
    output('Begin register position!');
    output(to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss'));
    FOR v_position IN c_position LOOP
      v_pos_count := 0;
      SELECT nvl(COUNT(1), 0)
        INTO v_pos_count
        FROM eng_ecn_approval_lists eeal
       WHERE 1 = 1
         AND eeal.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_POSITION
         AND eeal.attribute2 = v_position.position_id
         AND eeal.attribute3 = v_position.organization_id;
      IF v_pos_count = 0 THEN
        SELECT eng_ecn_approval_lists_s.nextval INTO p_list_id FROM dual;
        p_rowid := NULL;
        SELECT NAME
          INTO p_position_name
          FROM hr_all_positions_f hap
         WHERE 1 = 1
           AND hap.position_id = v_position.position_id
           AND rownum < 2;
        output('Insert Position:' || p_position_name);
        ENG_ECN_APPROVAL_LISTS_PKG.Insert_Row(X_Rowid              => p_rowid,
                                              X_Approval_List_Id   => p_list_id,
                                              X_Approval_List_Name => p_position_name || ':' ||
                                                                      p_list_id,
                                              X_Attribute1         => WF_APPROVE_CONSTANT_PKG.SOURCE_POSITION,
                                              X_Attribute2         => v_position.position_id,
                                              X_Attribute3         => v_position.organization_id,
                                              X_Creation_Date      => SYSDATE,
                                              X_Created_By         => fnd_global.USER_ID,
                                              X_Last_Update_Date   => SYSDATE,
                                              X_Last_Updated_By    => fnd_global.USER_ID);
      ELSE
        p_rowid             := NULL;
        p_list_id           := NULL;
        p_old_disabled_date := NULL;
        p_disabled_date     := NULL;
        SELECT ROWID, eea.approval_list_id, eea.disable_date
          INTO p_rowid, p_list_id, p_old_disabled_date
          FROM eng_ecn_approval_lists eea
         WHERE eea.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_POSITION
           AND eea.attribute2 = v_position.position_id
           AND eea.attribute3 = v_position.organization_id;
      END IF;
      p_index := 10;
      FOR v_person IN c_person(v_position.position_id,
                               v_position.organization_id) LOOP
        v_per_count := 0;
        SELECT nvl(COUNT(1), 0)
          INTO v_per_count
          FROM eng_ecn_approvers eep
         WHERE eep.approval_list_id = p_list_id
           AND eep.employee_id = v_person.person_id;
        /*select ppf.LAST_NAME
        into p_person_name
        from PER_PEOPLE_F ppf
        where 1 = 1
        and ppf.PERSON_ID = v_person.person_id
        and rownum < 2;*/
        IF v_per_count > 0 THEN
          p_rowid             := NULL;
          p_seq               := NULL;
          p_disabled_date     := NULL;
          p_old_disabled_date := NULL;
          SELECT ROWID, eep.sequence1, eep.disable_date
            INTO p_rowid, p_seq, p_old_disabled_date
            FROM eng_ecn_approvers eep
           WHERE eep.approval_list_id = p_list_id
             AND eep.employee_id = v_person.person_id;
          SELECT decode(v_person.effective_end_date,
                        to_date('4712/12/31', 'yyyy/mm/dd'),
                        NULL,
                        v_person.effective_end_date)
            INTO p_disabled_date
            FROM dual;
          IF nvl(p_disabled_date, to_date('1900-01-01', 'yyyy-mm-dd')) <>
             nvl(p_old_disabled_date, to_date('1900-01-01', 'yyyy-mm-dd')) THEN
            --v_person
            output('                  Update person:' ||
                   v_person.person_id);
            ENG_ECN_APPROVERS_PKG.Update_Row(X_Rowid            => p_rowid,
                                             X_Approval_List_Id => p_list_id,
                                             X_Employee_Id      => v_person.person_id,
                                             X_Sequence1        => p_seq,
                                             X_Disable_Date     => p_disabled_date,
                                             X_Last_Update_Date => SYSDATE,
                                             X_Last_Updated_By  => fnd_global.USER_ID);
          END IF;
        ELSE
          output('                  Insert person:' || v_person.person_id);
          p_rowid := NULL;
          ENG_ECN_APPROVERS_PKG.Insert_Row(X_Rowid            => p_rowid,
                                           X_Approval_List_Id => p_list_id,
                                           X_Employee_Id      => v_person.person_id,
                                           X_Sequence1        => p_index,
                                           X_Creation_Date    => SYSDATE,
                                           X_Created_By       => fnd_global.USER_ID,
                                           X_Last_Update_Date => SYSDATE,
                                           X_Last_Updated_By  => fnd_global.USER_ID);
        END IF;
        p_index := p_index + 10;
      END LOOP;
    END LOOP;
    output(to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss'));
    output(fnd_global.Newline);
    p_delete_count := 0;
    --first delete line, then delete header
    FOR v_person_delete IN c_person_delete LOOP
      ENG_ECN_APPROVERS_PKG.Delete_Row(v_person_delete.rowid);
      p_delete_count := p_delete_count + 1;
    END LOOP;
    output('                  Count of delete person ' || p_delete_count || ' !');
    p_delete_count := 0;
    FOR v_position_delete IN c_position_delete LOOP
      ENG_ECN_APPROVAL_LISTS_PKG.Delete_Row(v_position_delete.rowid);
      p_delete_count := p_delete_count + 1;
    END LOOP;
    output('                  Count of delete position ' || p_delete_count || ' !');
    output(fnd_global.Newline);
    output('End register position!');
    output('*******************************************************************/');
  END;
  PROCEDURE register_by_joborg IS
    --find all job
    CURSOR c_joborg IS
      SELECT paa.organization_id, paa.job_id
        FROM PER_ALL_ASSIGNMENTS_F paa
       WHERE 1 = 1
         AND paa.job_id IS NOT NULL
         AND paa.last_update_date >
             (SELECT last_update_date
                FROM wf_approve_role_update_tl
               WHERE rownum < 2)
         AND EXISTS
       (SELECT 1
                FROM fnd_user fu
               WHERE 1 = 1
                 AND fu.employee_id = paa.person_id
                 AND trunc(SYSDATE) BETWEEN nvl(fu.start_date, SYSDATE - 1) AND
                     nvl(fu.end_date, SYSDATE + 1))
         AND trunc(SYSDATE) BETWEEN
             nvl(paa.effective_start_date, SYSDATE - 1) AND
             nvl(paa.effective_end_date, SYSDATE + 1)
       GROUP BY paa.organization_id, paa.job_id;
    --find all person belong to job
    CURSOR c_person(p_job_id NUMBER, p_org_id NUMBER) IS
      SELECT paa.person_id, paa.effective_end_date
        FROM PER_ALL_ASSIGNMENTS_F paa
       WHERE 1 = 1
         AND paa.job_id = p_job_id
         AND EXISTS
       (SELECT 1
                FROM fnd_user fu
               WHERE 1 = 1
                 AND fu.employee_id = paa.person_id
                 AND trunc(SYSDATE) BETWEEN nvl(fu.start_date, SYSDATE - 1) AND
                     nvl(fu.end_date, SYSDATE + 1))
         AND trunc(SYSDATE) BETWEEN
             nvl(paa.effective_start_date, SYSDATE - 1) AND
             nvl(paa.effective_end_date, SYSDATE + 1)
         AND paa.organization_id = p_org_id;
    --job delete, role must delete
    CURSOR c_job_delete IS
      SELECT eeal.rowid
        FROM eng_ecn_approval_lists eeal
       WHERE 1 = 1
         AND eeal.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_JOBORG
         AND NOT EXISTS
       (SELECT 1
                FROM PER_ALL_ASSIGNMENTS_F paa
               WHERE 1 = 1
                 AND trunc(SYSDATE) BETWEEN
                     nvl(paa.effective_start_date, SYSDATE - 1) AND
                     nvl(paa.effective_end_date, SYSDATE + 1)
                 AND paa.job_id = eeal.attribute2
                 AND paa.organization_id = eeal.attribute3);
    --person need delete
    CURSOR c_person_delete IS
      SELECT eea.rowid
        FROM eng_ecn_approvers eea, eng_ecn_approval_lists eeal
       WHERE 1 = 1
         AND eea.approval_list_id = eeal.approval_list_id
         AND eeal.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_JOBORG
         AND NOT EXISTS
       (SELECT 1
                FROM PER_ALL_ASSIGNMENTS_F paa
               WHERE 1 = 1
                 AND trunc(SYSDATE) BETWEEN
                     nvl(paa.effective_start_date, SYSDATE - 1) AND
                     nvl(paa.effective_end_date, SYSDATE + 1)
                 AND paa.organization_id = eeal.attribute3
                 AND paa.job_id = eeal.attribute2
                 AND paa.person_id = eea.employee_id
                 and nvl(paa.ass_attribute2, 'N') = 'N');
    v_joborg            c_joborg%ROWTYPE;
    v_person            c_person%ROWTYPE;
    v_job_delete        c_job_delete%ROWTYPE;
    v_person_delete     c_person_delete%ROWTYPE;
    v_job_count         NUMBER := 0;
    v_per_count         NUMBER := 0;
    p_rowid             VARCHAR2(250);
    p_list_id           NUMBER;
    p_seq               NUMBER;
    p_index             NUMBER;
    p_delete_count      NUMBER := 0;
    p_job_name          VARCHAR2(100);
    p_person_name       VARCHAR2(100);
    p_disabled_date     DATE;
    p_old_disabled_date DATE;
    v_approvecnt        number;
  BEGIN
    output('/*******************************************************************');
    output('Begin register job by org!');
    FOR v_joborg IN c_joborg LOOP
      
      v_job_count := 0;
      SELECT nvl(COUNT(1), 0)
        INTO v_job_count
        FROM eng_ecn_approval_lists eeal
       WHERE 1 = 1
         AND eeal.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_JOBORG
         AND eeal.attribute2 = v_joborg.job_id
         AND eeal.attribute3 = v_joborg.organization_id;
      SELECT pj.NAME
        INTO p_job_name
        FROM PER_JOBS_VL pj
       WHERE pj.job_id = v_joborg.job_id
         AND rownum < 2;
      --job needn't update
      dbms_output.put_line(v_joborg.job_id||'-'||v_joborg.organization_id||'-'||v_job_count);
      IF v_job_count = 0 THEN
        SELECT eng_ecn_approval_lists_s.nextval INTO p_list_id FROM dual;
        p_rowid := NULL;
        output('Insert Job:' || p_job_name);
        dbms_output.put_line('Insert Job:' || p_job_name);
        ENG_ECN_APPROVAL_LISTS_PKG.Insert_Row(X_Rowid              => p_rowid,
                                              X_Approval_List_Id   => p_list_id,
                                              X_Approval_List_Name => p_job_name || ':' ||
                                                                      p_list_id,
                                              X_Attribute1         => WF_APPROVE_CONSTANT_PKG.SOURCE_JOBORG,
                                              X_Attribute2         => v_joborg.job_id,
                                              X_Attribute3         => v_joborg.organization_id,
                                              X_Creation_Date      => SYSDATE,
                                              X_Created_By         => fnd_global.USER_ID,
                                              X_Last_Update_Date   => SYSDATE,
                                              X_Last_Updated_By    => fnd_global.USER_ID);
      ELSE
        p_rowid             := NULL;
        p_list_id           := NULL;
        p_old_disabled_date := NULL;
        p_disabled_date     := NULL;
        SELECT ROWID, eea.approval_list_id, eea.disable_date
          INTO p_rowid, p_list_id, p_old_disabled_date
          FROM eng_ecn_approval_lists eea
         WHERE eea.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_JOBORG
           AND eea.attribute2 = v_joborg.job_id
           AND eea.attribute3 = v_joborg.organization_id;
      END IF;
      p_index := 10;
      FOR v_person IN c_person(v_joborg.job_id, v_joborg.organization_id) LOOP
        v_per_count := 0;
        SELECT nvl(COUNT(1), 0)
          INTO v_per_count
          FROM eng_ecn_approvers eep
         WHERE eep.approval_list_id = p_list_id
           AND eep.employee_id = v_person.person_id;
        SELECT ppf.LAST_NAME
          INTO p_person_name
          FROM PER_PEOPLE_F ppf
         WHERE 1 = 1
           AND ppf.PERSON_ID = v_person.person_id
           AND rownum < 2;
        IF v_per_count > 0 THEN
          select count(1)
            into v_approvecnt
            from wf_local_user_roles t
           where t.role_orig_system_id = p_list_id
             and t.role_orig_system = 'ENG_LIST';
          if v_approvecnt = 0 then
            output('                  Insert person:' || p_person_name);
            p_rowid := NULL;
            wf_local_synch.propagate_user_role(p_user_orig_system    => 'PER',
                                               p_user_orig_system_id => v_person.person_id,
                                               p_role_orig_system    => 'ENG_LIST',
                                               p_role_orig_system_id => p_list_id,
                                               p_start_date          => null,
                                               p_expiration_date     => to_date('4712/12/31',
                                                                                'yyyy/mm/dd'), --);
                                               p_overwrite           => TRUE); -- Bug 3817690
          
          end if;
          p_rowid             := NULL;
          p_seq               := NULL;
          p_disabled_date     := NULL;
          p_old_disabled_date := NULL;
          SELECT ROWID, eep.sequence1, eep.disable_date
            INTO p_rowid, p_seq, p_old_disabled_date
            FROM eng_ecn_approvers eep
           WHERE eep.approval_list_id = p_list_id
             AND eep.employee_id = v_person.person_id;
          SELECT decode(v_person.effective_end_date,
                        to_date('4712/12/31', 'yyyy/mm/dd'),
                        NULL,
                        v_person.effective_end_date)
            INTO p_disabled_date
            FROM dual;
          IF nvl(p_disabled_date, to_date('1900-01-01', 'yyyy-mm-dd')) <>
             nvl(p_old_disabled_date, to_date('1900-01-01', 'yyyy-mm-dd')) THEN
            --v_person
            output('                  Update person:' || p_person_name);
            ENG_ECN_APPROVERS_PKG.Update_Row(X_Rowid            => p_rowid,
                                             X_Approval_List_Id => p_list_id,
                                             X_Employee_Id      => v_person.person_id,
                                             X_Sequence1        => p_seq,
                                             X_Disable_Date     => p_disabled_date,
                                             X_Last_Update_Date => SYSDATE,
                                             X_Last_Updated_By  => fnd_global.USER_ID);
          END IF;
        ELSE
          output('                  Insert person:' || p_person_name);
          p_rowid := NULL;
          ENG_ECN_APPROVERS_PKG.Insert_Row(X_Rowid            => p_rowid,
                                           X_Approval_List_Id => p_list_id,
                                           X_Employee_Id      => v_person.person_id,
                                           X_Sequence1        => p_index,
                                           X_Creation_Date    => SYSDATE,
                                           X_Created_By       => fnd_global.USER_ID,
                                           X_Last_Update_Date => SYSDATE,
                                           X_Last_Updated_By  => fnd_global.USER_ID);
        END IF;
      
        p_index := p_index + 10;
      END LOOP;
    END LOOP;
    output(fnd_global.Newline);
    p_delete_count := 0;
    FOR v_person_delete IN c_person_delete LOOP
      ENG_ECN_APPROVERS_PKG.Delete_Row(v_person_delete.rowid);
      p_delete_count := p_delete_count + 1;
    END LOOP;
    output('                  Count of delete person ' || p_delete_count || ' !');
    p_delete_count := 0;
    FOR v_job_delete IN c_job_delete LOOP
      ENG_ECN_APPROVAL_LISTS_PKG.Delete_Row(v_job_delete.rowid);
      p_delete_count := p_delete_count + 1;
    END LOOP;
    output('                  Count of delete job ' || p_delete_count || ' !');
    output(fnd_global.Newline);
    output('End register job by org!');
    output('*******************************************************************/');
  END;
  PROCEDURE register_by_job IS
    --find all job not by org
    CURSOR c_job IS
      SELECT paa.job_id
        FROM PER_ALL_ASSIGNMENTS_F paa
       WHERE 1 = 1
         AND paa.job_id IS NOT NULL
         AND paa.last_update_date >
             (SELECT last_update_date
                FROM wf_approve_role_update_tl
               WHERE rownum < 2)
         AND EXISTS
       (SELECT 1
                FROM fnd_user fu
               WHERE 1 = 1
                 AND fu.employee_id = paa.person_id
                 AND trunc(SYSDATE) BETWEEN nvl(fu.start_date, SYSDATE - 1) AND
                     nvl(fu.end_date, SYSDATE + 1))
         AND trunc(SYSDATE) BETWEEN
             nvl(paa.effective_start_date, SYSDATE - 1) AND
             nvl(paa.effective_end_date, SYSDATE + 1)
       GROUP BY paa.job_id;
    --find all person belong to job
    CURSOR c_person(p_job_id NUMBER) IS
      SELECT paa.person_id, paa.effective_end_date
        FROM PER_ALL_ASSIGNMENTS_F paa
       WHERE 1 = 1
         AND paa.job_id = p_job_id
         AND EXISTS
       (SELECT 1
                FROM fnd_user fu
               WHERE 1 = 1
                 AND fu.employee_id = paa.person_id
                 AND trunc(SYSDATE) BETWEEN nvl(fu.start_date, SYSDATE - 1) AND
                     nvl(fu.end_date, SYSDATE + 1))
         AND trunc(SYSDATE) BETWEEN
             nvl(paa.effective_start_date, SYSDATE - 1) AND
             nvl(paa.effective_end_date, SYSDATE + 1);
    --job delete, role must delete
    CURSOR c_job_delete IS
      SELECT eeal.rowid
        FROM eng_ecn_approval_lists eeal
       WHERE 1 = 1
         AND eeal.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_JOB
         AND NOT EXISTS
       (SELECT 1
                FROM PER_ALL_ASSIGNMENTS_F paa
               WHERE 1 = 1
                 AND paa.job_id = eeal.attribute2
                 AND trunc(SYSDATE) BETWEEN
                     nvl(paa.effective_start_date, SYSDATE - 1) AND
                     nvl(paa.effective_end_date, SYSDATE + 1));
    --person need delete
    CURSOR c_person_delete IS
      SELECT eea.rowid
        FROM eng_ecn_approvers eea, eng_ecn_approval_lists eeal
       WHERE 1 = 1
         AND eea.approval_list_id = eeal.approval_list_id
         AND eeal.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_JOB
         AND NOT EXISTS
       (SELECT 1
                FROM PER_ALL_ASSIGNMENTS_F paa
               WHERE 1 = 1
                 AND paa.person_id = eea.employee_id
                 AND paa.job_id = eeal.attribute2
                 AND trunc(SYSDATE) BETWEEN
                     nvl(paa.effective_start_date, SYSDATE - 1) AND
                     nvl(paa.effective_end_date, SYSDATE + 1));
    v_job               c_job%ROWTYPE;
    v_person            c_person%ROWTYPE;
    v_job_delete        c_job_delete%ROWTYPE;
    v_person_delete     c_person_delete%ROWTYPE;
    v_job_count         NUMBER := 0;
    v_per_count         NUMBER := 0;
    p_rowid             VARCHAR2(250);
    p_list_id           NUMBER;
    p_seq               NUMBER;
    p_index             NUMBER;
    p_delete_count      NUMBER := 0;
    p_job_name          VARCHAR2(100);
    p_person_name       VARCHAR2(100);
    p_disabled_date     DATE;
    p_old_disabled_date DATE;
  BEGIN
    output('/*******************************************************************');
    output('Begin register job!');
    FOR v_job IN c_job LOOP
      v_job_count := 0;
      SELECT nvl(COUNT(1), 0)
        INTO v_job_count
        FROM eng_ecn_approval_lists eeal
       WHERE 1 = 1
         AND eeal.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_JOB
         AND eeal.attribute2 = v_job.job_id;
      SELECT pj.NAME
        INTO p_job_name
        FROM PER_JOBS_VL pj
       WHERE pj.job_id = v_job.job_id
         AND rownum < 2;
      IF v_job_count = 0 THEN
        SELECT eng_ecn_approval_lists_s.nextval INTO p_list_id FROM dual;
        p_rowid := NULL;
        output('Insert Job:' || p_job_name);
        ENG_ECN_APPROVAL_LISTS_PKG.Insert_Row(X_Rowid              => p_rowid,
                                              X_Approval_List_Id   => p_list_id,
                                              X_Approval_List_Name => p_job_name || ':' ||
                                                                      p_list_id,
                                              X_Attribute1         => WF_APPROVE_CONSTANT_PKG.SOURCE_JOB,
                                              X_Attribute2         => v_job.job_id,
                                              X_Creation_Date      => SYSDATE,
                                              X_Created_By         => fnd_global.USER_ID,
                                              X_Last_Update_Date   => SYSDATE,
                                              X_Last_Updated_By    => fnd_global.USER_ID);
      ELSE
        p_rowid             := NULL;
        p_list_id           := NULL;
        p_old_disabled_date := NULL;
        p_disabled_date     := NULL;
        SELECT ROWID, eea.approval_list_id, eea.disable_date
          INTO p_rowid, p_list_id, p_old_disabled_date
          FROM eng_ecn_approval_lists eea
         WHERE eea.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_JOB
           AND eea.attribute2 = v_job.job_id;
      END IF;
      p_index := 10;
      FOR v_person IN c_person(v_job.job_id) LOOP
        v_per_count := 0;
        SELECT nvl(COUNT(1), 0)
          INTO v_per_count
          FROM eng_ecn_approvers eep
         WHERE eep.approval_list_id = p_list_id
           AND eep.employee_id = v_person.person_id;
        SELECT ppf.LAST_NAME
          INTO p_person_name
          FROM PER_PEOPLE_F ppf
         WHERE 1 = 1
           AND ppf.PERSON_ID = v_person.person_id
           AND rownum < 2;
        IF v_per_count > 0 THEN
          p_rowid             := NULL;
          p_seq               := NULL;
          p_disabled_date     := NULL;
          p_old_disabled_date := NULL;
          SELECT ROWID, eep.sequence1, eep.disable_date
            INTO p_rowid, p_seq, p_old_disabled_date
            FROM eng_ecn_approvers eep
           WHERE eep.approval_list_id = p_list_id
             AND eep.employee_id = v_person.person_id;
          SELECT decode(v_person.effective_end_date,
                        to_date('4712/12/31', 'yyyy/mm/dd'),
                        NULL,
                        v_person.effective_end_date)
            INTO p_disabled_date
            FROM dual;
          IF nvl(p_disabled_date, to_date('1900-01-01', 'yyyy-mm-dd')) <>
             nvl(p_old_disabled_date, to_date('1900-01-01', 'yyyy-mm-dd')) THEN
            --v_person
            output('                  Update person:' || p_person_name);
            ENG_ECN_APPROVERS_PKG.Update_Row(X_Rowid            => p_rowid,
                                             X_Approval_List_Id => p_list_id,
                                             X_Employee_Id      => v_person.person_id,
                                             X_Sequence1        => p_seq,
                                             X_Disable_Date     => p_disabled_date,
                                             X_Last_Update_Date => SYSDATE,
                                             X_Last_Updated_By  => fnd_global.USER_ID);
          END IF;
        ELSE
          output('                  Insert person:' || p_person_name);
          p_rowid := NULL;
          ENG_ECN_APPROVERS_PKG.Insert_Row(X_Rowid            => p_rowid,
                                           X_Approval_List_Id => p_list_id,
                                           X_Employee_Id      => v_person.person_id,
                                           X_Sequence1        => p_index,
                                           X_Creation_Date    => SYSDATE,
                                           X_Created_By       => fnd_global.USER_ID,
                                           X_Last_Update_Date => SYSDATE,
                                           X_Last_Updated_By  => fnd_global.USER_ID);
        END IF;
        p_index := p_index + 10;
      END LOOP;
    END LOOP;
    output(fnd_global.Newline);
    p_delete_count := 0;
    FOR v_person_delete IN c_person_delete LOOP
      ENG_ECN_APPROVERS_PKG.Delete_Row(v_person_delete.rowid);
      p_delete_count := p_delete_count + 1;
    END LOOP;
    output('                  Count of delete person ' || p_delete_count || ' !');
    p_delete_count := 0;
    FOR v_job_delete IN c_job_delete LOOP
      ENG_ECN_APPROVAL_LISTS_PKG.Delete_Row(v_job_delete.rowid);
      p_delete_count := p_delete_count + 1;
    END LOOP;
    output('                  Count of delete job ' || p_delete_count || ' !');
    output(fnd_global.Newline);
    output('End register job!');
    output('*******************************************************************/');
  END;

  procedure init_security is
    i number;
  begin
    delete user_org;
    -- Test statements here
    for cr in (select user_id,
                      responsibility_id,
                      b.RESPONSIBILITY_APPLICATION_ID
                 from FND_USER_RESP_GROUPS_DIRECT b
                where end_date is null) loop
      begin
      
        cux_init_app_pkg.init(p_USER_ID      => cr.user_id,
                              p_RESP_ID      => cr.responsibility_id,
                              p_RESP_APPL_ID => cr.responsibility_application_id);
        select employee_id into i from fnd_user where user_id = cr.user_id;
        insert into user_org
          (organization_id,
           organization_name,
           legal_entity_id,
           legal_entity_name,
           user_id,
           employee_id)
          select organization_id,
                 organization_name,
                 legal_entity_id,
                 legal_entity_name,
                 cr.user_id,
                 i
            from mo_glob_org_access_tmp;
      exception
        when others then
          null;
      end;
    end loop;
  end;

  PROCEDURE register_by_jobou IS
    --find all job by ou
    CURSOR c_jobou(p_dttm DATE) IS
      SELECT hou.organization_id, paa.job_id
        FROM PER_ALL_ASSIGNMENTS_F paa, hr_operating_units hou
       WHERE 1 = 1
         AND paa.job_id IS NOT NULL
            --peter add 2014/09/20
         AND (EXISTS
              (SELECT 1
                 FROM hr_operating_units ou, hr_locations_all hla
                WHERE 1 = 1
                  AND paa.location_id = hla.location_id
                  AND hla.location_code = ou.name) OR paa.job_id <> 160)
            --add end
         AND (paa.last_update_date > p_dttm)
         AND trunc(SYSDATE) BETWEEN nvl(hou.date_from, SYSDATE - 1) AND
             nvl(hou.date_to, SYSDATE + 1)
         AND EXISTS
       (SELECT 1
                FROM fnd_user fu
               WHERE 1 = 1
                 AND fu.employee_id = paa.person_id
                 AND trunc(SYSDATE) BETWEEN nvl(fu.start_date, SYSDATE - 1) AND
                     nvl(fu.end_date, SYSDATE + 1))
         AND trunc(SYSDATE) BETWEEN
             nvl(paa.effective_start_date, SYSDATE - 1) AND
             nvl(paa.effective_end_date, SYSDATE + 1)
      UNION
      SELECT hou.organization_id, paa.job_id
        FROM PER_ALL_ASSIGNMENTS_F paa, hr_operating_units hou
       WHERE 1 = 1
         AND paa.job_id IS NOT NULL
            --peter add 2014/09/20
         AND (EXISTS
              (SELECT 1
                 FROM hr_operating_units ou, hr_locations_all hla
                WHERE 1 = 1
                  AND paa.location_id = hla.location_id
                  AND hla.location_code = ou.name) OR paa.job_id <> 160)
            --add end
         AND ((paa.person_id, hou.organization_id) IN
             (SELECT FU.EMPLOYEE_ID, FSO.organization_id
                 FROM FND_PROFILE_OPTION_VALUES    FPOV, --PROFLIE VALUE
                      FND_USER_RESP_GROUPS_DIRECT  FUR, --USER-RESP
                      PER_SECURITY_ORGANIZATIONS_V FSO, --SECURITY PROFILE LINE
                      PER_SECURITY_PROFILES_V      FSP, --SECURITY PROFILE HEADER
                      FND_USER                     FU --USER
                WHERE 1 = 1
                  AND (fpov.last_update_date > p_dttm OR
                      fur.LAST_UPDATE_DATE > p_dttm OR
                      fso.last_update_date > p_dttm OR
                      fsp.last_update_date > p_dttm)
                  AND FPOV.LEVEL_VALUE = FUR.RESPONSIBILITY_ID
                  AND FPOV.LEVEL_ID = 10003 --RESP LEVEL
                  AND FPOV.PROFILE_OPTION_ID =
                      (SELECT FPO.PROFILE_OPTION_ID
                         FROM FND_PROFILE_OPTIONS_VL FPO
                        WHERE FPO.PROFILE_OPTION_NAME =
                              'XLA_MO_SECURITY_PROFILE_LEVEL')
                  AND FSO.security_profile_id = FSP.security_profile_id
                  AND FSP.org_security_mode = 'HIER'
                  AND TO_CHAR(FPOV.PROFILE_OPTION_VALUE) =
                      TO_CHAR(FSO.security_profile_id)
                  AND FU.USER_ID = FUR.user_id
                  AND trunc(SYSDATE) BETWEEN
                      nvl(fur.START_DATE, SYSDATE - 1) AND
                      nvl(fur.END_DATE, SYSDATE + 1)))
         AND trunc(SYSDATE) BETWEEN nvl(hou.date_from, SYSDATE - 1) AND
             nvl(hou.date_to, SYSDATE + 1)
         AND EXISTS
       (SELECT 1
                FROM fnd_user fu
               WHERE 1 = 1
                 AND fu.employee_id = paa.person_id
                 AND trunc(SYSDATE) BETWEEN nvl(fu.start_date, SYSDATE - 1) AND
                     nvl(fu.end_date, SYSDATE + 1))
         AND trunc(SYSDATE) BETWEEN
             nvl(paa.effective_start_date, SYSDATE - 1) AND
             nvl(paa.effective_end_date, SYSDATE + 1)
      UNION
      SELECT hou.organization_id, paa.job_id
        FROM PER_ALL_ASSIGNMENTS_F paa, hr_operating_units hou
       WHERE 1 = 1
         AND paa.job_id IS NOT NULL
            --peter add 2014/09/20
         AND (EXISTS
              (SELECT 1
                 FROM hr_operating_units ou, hr_locations_all hla
                WHERE 1 = 1
                  AND paa.location_id = hla.location_id
                  AND hla.location_code = ou.name) OR paa.job_id <> 160)
            --add end
         AND (EXISTS
              (SELECT FU.EMPLOYEE_ID
                 FROM FND_PROFILE_OPTION_VALUES   FPOV, --PROFLIE VALUE
                      FND_USER_RESP_GROUPS_DIRECT FUR, --USER-RESP
                      --PER_SECURITY_ORGANIZATIONS_V FSO, --SECURITY PROFILE LINE
                      PER_SECURITY_PROFILES_V FSP, --SECURITY PROFILE HEADER
                      FND_USER                FU --USER
                WHERE 1 = 1
                  AND FPOV.LEVEL_VALUE = FUR.RESPONSIBILITY_ID
                  AND FPOV.LEVEL_ID = 10003 --RESP LEVEL
                  AND FPOV.PROFILE_OPTION_ID =
                      (SELECT FPO.PROFILE_OPTION_ID
                         FROM FND_PROFILE_OPTIONS_VL FPO
                        WHERE FPO.PROFILE_OPTION_NAME =
                              'XLA_MO_SECURITY_PROFILE_LEVEL')
                     --AND FSO.security_profile_id = FSP.security_profile_id
                  AND FSP.org_security_mode = 'NONE' --all ORGANIZATION
                  AND TO_CHAR(FPOV.PROFILE_OPTION_VALUE) =
                      TO_CHAR(FSP.security_profile_id)
                  AND FU.USER_ID = FUR.user_id
                  AND trunc(SYSDATE) BETWEEN nvl(fur.START_DATE, SYSDATE - 1) AND
                      nvl(fur.END_DATE, SYSDATE + 1)
                  AND fu.EMPLOYEE_ID = paa.person_id))
         AND trunc(SYSDATE) BETWEEN nvl(hou.date_from, SYSDATE - 1) AND
             nvl(hou.date_to, SYSDATE + 1)
         AND EXISTS
       (SELECT 1
                FROM fnd_user fu
               WHERE 1 = 1
                 AND fu.employee_id = paa.person_id
                 AND trunc(SYSDATE) BETWEEN nvl(fu.start_date, SYSDATE - 1) AND
                     nvl(fu.end_date, SYSDATE + 1))
         AND trunc(SYSDATE) BETWEEN
             nvl(paa.effective_start_date, SYSDATE - 1) AND
             nvl(paa.effective_end_date, SYSDATE + 1);
    /* cursor c_jobou(p_dttm date) is
    select hou.organization_id, paa.job_id
    from PER_ALL_ASSIGNMENTS_F paa, hr_operating_units hou
    where 1 = 1
    and paa.job_id is not null
    --peter add 2014/09/20
    and (exists
    (select 1
    from hr_operating_units ou, hr_locations_all hla
    where 1 = 1
    and paa.location_id = hla.location_id
    and hla.location_code = ou.name)
    or paa.job_id <> 160)
    --add end
    and
    (paa.last_update_date >
    p_dttm or
    (exists
    (SELECT FPOV.LEVEL_ID
    ,FPOV.LEVEL_VALUE
    ,FPOV.PROFILE_OPTION_VALUE
    ,FUR.USER_ID
    ,FSO.organization_id
    FROM FND_PROFILE_OPTION_VALUES    FPOV
    , --PROFLIE VALUE
    FND_USER_RESP_GROUPS_DIRECT  FUR
    , --USER-RESP
    PER_SECURITY_ORGANIZATIONS_V FSO
    , --SECURITY PROFILE LINE
    PER_SECURITY_PROFILES_V      FSP
    , --SECURITY PROFILE HEADER
    FND_USER                     FU --USER
    WHERE 1 = 1
    and (fpov.last_update_date >
    (select last_update_date
    from wf_approve_role_update_tl
    where rownum < 2) or
    fur.LAST_UPDATE_DATE >
    (select last_update_date
    from wf_approve_role_update_tl
    where rownum < 2) or
    fso.last_update_date >
    (select last_update_date
    from wf_approve_role_update_tl
    where rownum < 2) or
    fsp.last_update_date >
    (select last_update_date
    from wf_approve_role_update_tl
    where rownum < 2))
    AND FPOV.LEVEL_VALUE = FUR.RESPONSIBILITY_ID
    AND FPOV.LEVEL_ID = 10003 --RESP LEVEL
    AND FPOV.PROFILE_OPTION_ID =
    (SELECT FPO.PROFILE_OPTION_ID
    FROM FND_PROFILE_OPTIONS_VL FPO
    WHERE FPO.PROFILE_OPTION_NAME =
    'XLA_MO_SECURITY_PROFILE_LEVEL')
    AND FSO.security_profile_id = FSP.security_profile_id
    AND FSP.org_security_mode = 'HIER'
    AND TO_CHAR(FPOV.PROFILE_OPTION_VALUE) =
    TO_CHAR(FSO.security_profile_id)
    AND FU.USER_ID = FUR.user_id
    and trunc(sysdate) between
    nvl(fur.START_DATE
    ,sysdate - 1) and
    nvl(fur.END_DATE
    ,sysdate + 1)
    AND FU.EMPLOYEE_ID = paa.person_id
    AND FSO.organization_id = hou.organization_id) or
    exists
    (SELECT FPOV.LEVEL_ID
    ,FPOV.LEVEL_VALUE
    ,FPOV.PROFILE_OPTION_VALUE
    ,FUR.USER_ID
    FROM FND_PROFILE_OPTION_VALUES   FPOV
    , --PROFLIE VALUE
    FND_USER_RESP_GROUPS_DIRECT FUR
    , --USER-RESP
    --PER_SECURITY_ORGANIZATIONS_V FSO, --SECURITY PROFILE LINE
    PER_SECURITY_PROFILES_V FSP
    , --SECURITY PROFILE HEADER
    FND_USER                FU --USER
    WHERE 1 = 1
    AND FPOV.LEVEL_VALUE = FUR.RESPONSIBILITY_ID
    AND FPOV.LEVEL_ID = 10003 --RESP LEVEL
    AND FPOV.PROFILE_OPTION_ID =
    (SELECT FPO.PROFILE_OPTION_ID
    FROM FND_PROFILE_OPTIONS_VL FPO
    WHERE FPO.PROFILE_OPTION_NAME =
    'XLA_MO_SECURITY_PROFILE_LEVEL')
    --AND FSO.security_profile_id = FSP.security_profile_id
    AND FSP.org_security_mode = 'NONE' --all ORGANIZATION
    AND TO_CHAR(FPOV.PROFILE_OPTION_VALUE) =
    TO_CHAR(FSP.security_profile_id)
    AND FU.USER_ID = FUR.user_id
    and trunc(sysdate) between
    nvl(fur.START_DATE
    ,sysdate - 1) and
    nvl(fur.END_DATE
    ,sysdate + 1)
    AND FU.EMPLOYEE_ID = paa.person_id)))
    and
    trunc(sysdate) between nvl(hou.date_from
    ,sysdate - 1) and
    nvl(hou.date_to
    ,sysdate + 1)
    and exists (select 1
    from fnd_user fu
    where 1 = 1
    and fu.employee_id = paa.person_id
    and trunc(sysdate) between
    nvl(fu.start_date
    ,sysdate - 1) and
    nvl(fu.end_date
    ,sysdate + 1))
    and trunc(sysdate) between
    nvl(paa.effective_start_date
    ,sysdate - 1) and
    nvl(paa.effective_end_date
    ,sysdate + 1)
    group by hou.organization_id, paa.job_id;*/
    --find all person belong to job, not by ou
    CURSOR c_person(p_job_id NUMBER, p_ou_id NUMBER) IS
      SELECT paa.person_id, paa.effective_end_date
        FROM PER_ALL_ASSIGNMENTS_F paa
       WHERE 1 = 1
         AND paa.job_id = p_job_id
            --peter add 2014/09/20
         AND (EXISTS
              (SELECT 1
                 FROM hr_operating_units ou, hr_locations_all hla
                WHERE 1 = 1
                  AND paa.location_id = hla.location_id
                  AND hla.location_code = ou.name) OR paa.job_id <> 160)
            --add end
         AND EXISTS
       (SELECT 1
                FROM fnd_user fu
               WHERE 1 = 1
                 AND fu.employee_id = paa.person_id
                 AND trunc(SYSDATE) BETWEEN nvl(fu.start_date, SYSDATE - 1) AND
                     nvl(fu.end_date, SYSDATE + 1))
         AND trunc(SYSDATE) BETWEEN
             nvl(paa.effective_start_date, SYSDATE - 1) AND
             nvl(paa.effective_end_date, SYSDATE + 1)
      /*and (exists
      (SELECT FPOV.LEVEL_ID,
      FPOV.LEVEL_VALUE,
      FPOV.PROFILE_OPTION_VALUE,
      FUR.USER_ID,
      FSO.organization_id
      FROM FND_PROFILE_OPTION_VALUES    FPOV, --PROFLIE VALUE
      FND_USER_RESP_GROUPS_DIRECT  FUR, --USER-RESP
      PER_SECURITY_ORGANIZATIONS_V FSO, --SECURITY PROFILE LINE
      PER_SECURITY_PROFILES_V      FSP, --SECURITY PROFILE HEADER
      FND_USER                     FU --USER
      WHERE 1 = 1
      AND FPOV.LEVEL_VALUE = FUR.RESPONSIBILITY_ID
      AND FPOV.LEVEL_ID = 10003 --RESP LEVEL
      AND FPOV.PROFILE_OPTION_ID =
      (SELECT FPO.PROFILE_OPTION_ID
      FROM FND_PROFILE_OPTIONS_VL FPO
      WHERE FPO.PROFILE_OPTION_NAME =
      'XLA_MO_SECURITY_PROFILE_LEVEL')
      AND FSO.security_profile_id = FSP.security_profile_id
      AND FSP.org_security_mode = 'HIER'
      AND TO_CHAR(FPOV.PROFILE_OPTION_VALUE) =
      TO_CHAR(FSO.security_profile_id)
      AND FU.USER_ID = FUR.user_id
      and trunc(sysdate) between nvl(fur.START_DATE, sysdate - 1) and
      nvl(fur.END_DATE, sysdate + 1)
      AND FU.EMPLOYEE_ID =  paa.person_id
      AND FSO.organization_id = p_ou_id) or exists
      (SELECT FPOV.LEVEL_ID,
      FPOV.LEVEL_VALUE,
      FPOV.PROFILE_OPTION_VALUE,
      FUR.USER_ID
      FROM FND_PROFILE_OPTION_VALUES   FPOV, --PROFLIE VALUE
      FND_USER_RESP_GROUPS_DIRECT FUR, --USER-RESP
      --PER_SECURITY_ORGANIZATIONS_V FSO, --SECURITY PROFILE LINE
      PER_SECURITY_PROFILES_V FSP, --SECURITY PROFILE HEADER
      FND_USER                FU --USER
      WHERE 1 = 1
      AND FPOV.LEVEL_VALUE = FUR.RESPONSIBILITY_ID
      AND FPOV.LEVEL_ID = 10003 --RESP LEVEL
      AND FPOV.PROFILE_OPTION_ID =
      (SELECT FPO.PROFILE_OPTION_ID
      FROM FND_PROFILE_OPTIONS_VL FPO
      WHERE FPO.PROFILE_OPTION_NAME =
      'XLA_MO_SECURITY_PROFILE_LEVEL')
      --AND FSO.security_profile_id = FSP.security_profile_id
      AND FSP.org_security_mode = 'NONE' --all ORGANIZATION
      AND TO_CHAR(FPOV.PROFILE_OPTION_VALUE) =
      TO_CHAR(FSP.security_profile_id)
      AND FU.USER_ID = FUR.user_id
      and trunc(sysdate) between nvl(fur.START_DATE, sysdate - 1) and
      nvl(fur.END_DATE, sysdate + 1)
      AND FU.EMPLOYEE_ID = paa.person_id))*/
      ;
    --job and ou delete, role must delete
    CURSOR c_job_delete IS
      SELECT eeal.rowid
        FROM eng_ecn_approval_lists eeal
       WHERE 1 = 1
         AND eeal.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_JOBOU
            --job delete
         AND (NOT EXISTS
              (SELECT 1
                 FROM PER_ALL_ASSIGNMENTS_F paa
                WHERE 1 = 1
                     --peter add 2014/09/20
                  AND (EXISTS
                       (SELECT 1
                          FROM hr_operating_units ou, hr_locations_all hla
                         WHERE 1 = 1
                           AND paa.location_id = hla.location_id
                           AND hla.location_code = ou.name
                           AND eeal.attribute3 = ou.organization_id) OR
                       paa.job_id <> 160)
                     --add end
                  AND SYSDATE BETWEEN
                      nvl(paa.effective_start_date, SYSDATE - 1) AND
                      nvl(paa.effective_end_date, SYSDATE + 1)
                  AND paa.job_id = eeal.attribute2)
             --ou delete
              OR NOT EXISTS
              (SELECT 1
                 FROM hr_operating_units hou
                WHERE hou.organization_id = eeal.attribute3
                  AND trunc(SYSDATE) BETWEEN nvl(hou.date_from, SYSDATE - 1) AND
                      nvl(hou.date_to, SYSDATE + 1)));
    --person need delete
    CURSOR c_person_delete IS
      SELECT eea.rowid
        FROM eng_ecn_approvers eea, eng_ecn_approval_lists eeal
       WHERE 1 = 1
         AND eea.approval_list_id = eeal.approval_list_id
         AND eeal.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_JOBOU
            --job assignment delete for people
         AND (NOT EXISTS
              (SELECT 1
                 FROM PER_ALL_ASSIGNMENTS_F paa
                WHERE 1 = 1
                     --peter add 2014/09/20
                  AND (EXISTS
                       (SELECT 1
                          FROM hr_locations_all hla, hr_operating_units hou
                         WHERE 1 = 1
                           AND hla.location_code = hou.name
                           AND hla.location_id = paa.location_id
                           AND eeal.attribute3 = hou.organization_id) OR
                       paa.job_id <> 160)
                     -- add end
                  AND trunc(SYSDATE) BETWEEN
                      nvl(paa.effective_start_date, SYSDATE - 1) AND
                      nvl(paa.effective_end_date, SYSDATE + 1)
                  AND paa.person_id = eea.employee_id
                  AND paa.job_id = eeal.attribute2)
             --profile'ou delete for people
              OR
              NOT
               (EXISTS
                (SELECT FPOV.LEVEL_ID,
                        FPOV.LEVEL_VALUE,
                        FPOV.PROFILE_OPTION_VALUE,
                        FUR.USER_ID,
                        FSO.organization_id
                   FROM FND_PROFILE_OPTION_VALUES    FPOV, --PROFLIE VALUE
                        FND_USER_RESP_GROUPS_DIRECT  FUR, --USER-RESP
                        PER_SECURITY_ORGANIZATIONS_V FSO, --SECURITY PROFILE LINE
                        PER_SECURITY_PROFILES_V      FSP, --SECURITY PROFILE HEADER
                        FND_USER                     FU --USER
                  WHERE 1 = 1
                    AND FPOV.LEVEL_VALUE = FUR.RESPONSIBILITY_ID
                    AND FPOV.LEVEL_ID = 10003 --RESP LEVEL
                    AND FPOV.PROFILE_OPTION_ID =
                        (SELECT FPO.PROFILE_OPTION_ID
                           FROM FND_PROFILE_OPTIONS_VL FPO
                          WHERE FPO.PROFILE_OPTION_NAME =
                                'XLA_MO_SECURITY_PROFILE_LEVEL')
                    AND FSO.security_profile_id = FSP.security_profile_id
                    AND FSP.org_security_mode = 'HIER'
                    AND TO_CHAR(FPOV.PROFILE_OPTION_VALUE) =
                        TO_CHAR(FSO.security_profile_id)
                    AND FU.USER_ID = FUR.user_id
                    AND trunc(SYSDATE) BETWEEN nvl(fur.START_DATE, SYSDATE - 1) AND
                        nvl(fur.END_DATE, SYSDATE + 1)
                    AND FU.EMPLOYEE_ID = EEA.EMPLOYEE_ID
                    AND FSO.organization_id = EEAL.ATTRIBUTE3) OR EXISTS
                (SELECT FPOV.LEVEL_ID,
                        FPOV.LEVEL_VALUE,
                        FPOV.PROFILE_OPTION_VALUE,
                        FUR.USER_ID
                   FROM FND_PROFILE_OPTION_VALUES   FPOV, --PROFLIE VALUE
                        FND_USER_RESP_GROUPS_DIRECT FUR, --USER-RESP
                        --PER_SECURITY_ORGANIZATIONS_V FSO, --SECURITY PROFILE LINE
                        PER_SECURITY_PROFILES_V FSP, --SECURITY PROFILE HEADER
                        FND_USER                FU --USER
                  WHERE 1 = 1
                    AND FPOV.LEVEL_VALUE = FUR.RESPONSIBILITY_ID
                    AND FPOV.LEVEL_ID = 10003 --RESP LEVEL
                    AND FPOV.PROFILE_OPTION_ID =
                        (SELECT FPO.PROFILE_OPTION_ID
                           FROM FND_PROFILE_OPTIONS_VL FPO
                          WHERE FPO.PROFILE_OPTION_NAME =
                                'XLA_MO_SECURITY_PROFILE_LEVEL')
                       --AND FSO.security_profile_id = FSP.security_profile_id
                    AND FSP.org_security_mode = 'NONE' --all ORGANIZATION
                    AND TO_CHAR(FPOV.PROFILE_OPTION_VALUE) =
                        TO_CHAR(FSP.security_profile_id)
                    AND FU.USER_ID = FUR.user_id
                    AND trunc(SYSDATE) BETWEEN nvl(fur.START_DATE, SYSDATE - 1) AND
                        nvl(fur.END_DATE, SYSDATE + 1)
                    AND FU.EMPLOYEE_ID = EEA.EMPLOYEE_ID)));
    v_joborg            c_jobou%ROWTYPE;
    v_person            c_person%ROWTYPE;
    v_job_delete        c_job_delete%ROWTYPE;
    v_person_delete     c_person_delete%ROWTYPE;
    v_job_count         NUMBER := 0;
    v_per_count         NUMBER := 0;
    p_rowid             VARCHAR2(250);
    p_list_id           NUMBER;
    p_seq               NUMBER;
    p_index             NUMBER;
    p_delete_count      NUMBER := 0;
    p_job_name          VARCHAR2(100);
    p_person_name       VARCHAR2(100);
    p_disabled_date     DATE;
    p_old_disabled_date DATE;
    v_dttm              DATE;
  BEGIN
    output('/*******************************************************************');
    output('Begin register job by ou!');
    SELECT last_update_date
      INTO v_dttm
      FROM wf_approve_role_update_tl
     WHERE rownum < 2;
    FOR v_joborg IN c_jobou(v_dttm) LOOP
      v_job_count := 0;
      SELECT nvl(COUNT(1), 0)
        INTO v_job_count
        FROM eng_ecn_approval_lists eeal
       WHERE 1 = 1
         AND eeal.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_JOBOU
         AND eeal.attribute2 = v_joborg.job_id
         AND eeal.attribute3 = v_joborg.organization_id;
      SELECT pj.NAME
        INTO p_job_name
        FROM PER_JOBS_VL pj
       WHERE pj.job_id = v_joborg.job_id
         AND rownum < 2;
      --job needn't update
      IF v_job_count = 0 THEN
        SELECT eng_ecn_approval_lists_s.nextval INTO p_list_id FROM dual;
        p_rowid := NULL;
        output('Insert Job:' || p_job_name);
        ENG_ECN_APPROVAL_LISTS_PKG.Insert_Row(X_Rowid              => p_rowid,
                                              X_Approval_List_Id   => p_list_id,
                                              X_Approval_List_Name => p_job_name || ':' ||
                                                                      p_list_id,
                                              X_Attribute1         => WF_APPROVE_CONSTANT_PKG.SOURCE_JOBOU,
                                              X_Attribute2         => v_joborg.job_id,
                                              X_Attribute3         => v_joborg.organization_id,
                                              X_Creation_Date      => SYSDATE,
                                              X_Created_By         => fnd_global.USER_ID,
                                              X_Last_Update_Date   => SYSDATE,
                                              X_Last_Updated_By    => fnd_global.USER_ID);
      ELSE
        p_rowid             := NULL;
        p_list_id           := NULL;
        p_old_disabled_date := NULL;
        p_disabled_date     := NULL;
        SELECT ROWID, eea.approval_list_id, eea.disable_date
          INTO p_rowid, p_list_id, p_old_disabled_date
          FROM eng_ecn_approval_lists eea
         WHERE eea.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_JOBOU
           AND eea.attribute2 = v_joborg.job_id
           AND eea.attribute3 = v_joborg.organization_id;
      END IF;
      p_index := 10;
      FOR v_person IN c_person(v_joborg.job_id, v_joborg.organization_id) LOOP
        v_per_count := 0;
        SELECT nvl(COUNT(1), 0)
          INTO v_per_count
          FROM eng_ecn_approvers eep
         WHERE eep.approval_list_id = p_list_id
           AND eep.employee_id = v_person.person_id;
        /*select ppf.LAST_NAME
        into p_person_name
        from PER_PEOPLE_F ppf
        where 1 = 1
        and ppf.PERSON_ID = v_person.person_id
        and rownum < 2;*/
        IF v_per_count > 0 THEN
          p_rowid             := NULL;
          p_seq               := NULL;
          p_disabled_date     := NULL;
          p_old_disabled_date := NULL;
          SELECT ROWID, eep.sequence1, eep.disable_date
            INTO p_rowid, p_seq, p_old_disabled_date
            FROM eng_ecn_approvers eep
           WHERE eep.approval_list_id = p_list_id
             AND eep.employee_id = v_person.person_id;
          SELECT decode(v_person.effective_end_date,
                        to_date('4712/12/31', 'yyyy/mm/dd'),
                        NULL,
                        v_person.effective_end_date)
            INTO p_disabled_date
            FROM dual;
          IF nvl(p_disabled_date, to_date('1900-01-01', 'yyyy-mm-dd')) <>
             nvl(p_old_disabled_date, to_date('1900-01-01', 'yyyy-mm-dd')) THEN
            --v_person
            output('                  Update person:' ||
                   v_person.person_id);
            ENG_ECN_APPROVERS_PKG.Update_Row(X_Rowid            => p_rowid,
                                             X_Approval_List_Id => p_list_id,
                                             X_Employee_Id      => v_person.person_id,
                                             X_Sequence1        => p_seq,
                                             X_Disable_Date     => p_disabled_date,
                                             X_Last_Update_Date => SYSDATE,
                                             X_Last_Updated_By  => fnd_global.USER_ID);
          END IF;
        ELSE
          output('                  Insert person:' || v_person.person_id);
          p_rowid := NULL;
          ENG_ECN_APPROVERS_PKG.Insert_Row(X_Rowid            => p_rowid,
                                           X_Approval_List_Id => p_list_id,
                                           X_Employee_Id      => v_person.person_id,
                                           X_Sequence1        => p_index,
                                           X_Creation_Date    => SYSDATE,
                                           X_Created_By       => fnd_global.USER_ID,
                                           X_Last_Update_Date => SYSDATE,
                                           X_Last_Updated_By  => fnd_global.USER_ID);
        END IF;
        p_index := p_index + 10;
      END LOOP;
    END LOOP;
  
    output(fnd_global.Newline);
    p_delete_count := 0;
    output(to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss'));
    FOR v_person_delete IN c_person_delete LOOP
      ENG_ECN_APPROVERS_PKG.Delete_Row(v_person_delete.rowid);
      p_delete_count := p_delete_count + 1;
    END LOOP;
    output('                  Count of delete person ' || p_delete_count || ' !');
    p_delete_count := 0;
    FOR v_job_delete IN c_job_delete LOOP
      ENG_ECN_APPROVAL_LISTS_PKG.Delete_Row(v_job_delete.rowid);
      p_delete_count := p_delete_count + 1;
    END LOOP;
    output('                  Count of delete job ' || p_delete_count || ' !');
    output(fnd_global.Newline);
    output('End register job by ou!');
    output('*******************************************************************/');
  END;

  PROCEDURE register_by_jobou_new IS
    --find all job by ou
    CURSOR c_jobou IS
      select distinct a.job_id, b.organization_id, a.person_id
        from per_all_assignments_f a, user_org b, fnd_user c
       where sysdate between a.effective_start_date and
             a.effective_end_date
         and a.person_id = c.employee_id
         and b.user_id = c.user_id
         and a.job_id is not null
         and (EXISTS (SELECT 1
                        FROM hr_operating_units ou, hr_locations_all hla
                       WHERE 1 = 1
                         AND a.location_id = hla.location_id
                         AND hla.location_code = ou.name
                         and ou.organization_id = b.organization_id) OR
              a.job_id <> 160)
              and nvl(a.ass_attribute2, 'N') = 'N';
  
    --job and ou delete, role must delete
    CURSOR c_job_delete IS
      SELECT eeal.rowid
        FROM eng_ecn_approval_lists eeal
       WHERE 1 = 1
         AND eeal.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_JOBOU
            --job delete
         AND NOT EXISTS
       (select 1
                from (select distinct a.job_id,
                                      b.organization_id,
                                      a.person_id
                        from per_all_assignments_f a, user_org b, fnd_user c
                       where trunc(sysdate) between a.effective_start_date and
                             a.effective_end_date
                         and a.person_id = c.employee_id
                         and b.user_id = c.user_id
                         and a.job_id is not null
                         and (EXISTS (SELECT 1
                                 FROM hr_operating_units ou,
                                      hr_locations_all   hla
                                WHERE 1 = 1
                                  AND a.location_id = hla.location_id
                                  AND hla.location_code = ou.name) OR
                              a.job_id <> 160)
                              and nvl(a.ass_attribute2, 'N') = 'N') a
               where a.job_id = eeal.attribute2
               
                 and a.organization_id = eeal.attribute3);
    --person need delete
    CURSOR c_person_delete IS
      SELECT eea.rowid
        FROM eng_ecn_approvers eea, eng_ecn_approval_lists eeal
       WHERE 1 = 1
         AND eea.approval_list_id = eeal.approval_list_id
         AND eeal.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_JOBOU
            --job assignment delete for people
         and not exists
       (select 1
                from (select distinct a.job_id,
                                      b.organization_id,
                                      a.person_id
                        from per_all_assignments_f a, user_org b, fnd_user c
                       where trunc(sysdate) between a.effective_start_date and
                             a.effective_end_date
                         and a.person_id = c.employee_id
                         and b.user_id = c.user_id
                         and a.job_id is not null
                         and (EXISTS
                              (SELECT 1
                                 FROM hr_operating_units ou,
                                      hr_locations_all   hla
                                WHERE 1 = 1
                                  AND a.location_id = hla.location_id
                                  AND hla.location_code = ou.name
                                  and b.organization_id = ou.organization_id) OR
                              a.job_id <> 160)
                              and nvl(a.ass_attribute2, 'N') = 'N') a
               where eeal.attribute2 = a.job_id
                 and eeal.attribute3 = a.organization_id
                 and eea.employee_id = a.person_id);
    v_joborg c_jobou%ROWTYPE;
    -- v_person            c_person%ROWTYPE;
    v_job_delete        c_job_delete%ROWTYPE;
    v_person_delete     c_person_delete%ROWTYPE;
    v_job_count         NUMBER := 0;
    v_per_count         NUMBER := 0;
    p_rowid             VARCHAR2(250);
    p_list_id           NUMBER;
    p_seq               NUMBER;
    p_index             NUMBER;
    p_delete_count      NUMBER := 0;
    p_job_name          VARCHAR2(100);
    p_person_name       VARCHAR2(100);
    p_disabled_date     DATE;
    p_old_disabled_date DATE;
    v_dttm              DATE;
  BEGIN
  
    output('/*******************************************************************');
    output('Begin register job by ou!');
    init_security;
    SELECT last_update_date
      INTO v_dttm
      FROM wf_approve_role_update_tl
     WHERE rownum < 2;
  
    p_index := 10;
  
    FOR v_joborg IN c_jobou LOOP
      v_job_count := 0;
      SELECT nvl(COUNT(1), 0)
        INTO v_job_count
        FROM eng_ecn_approval_lists eeal
       WHERE 1 = 1
         AND eeal.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_JOBOU
         AND eeal.attribute2 = v_joborg.job_id
         AND eeal.attribute3 = v_joborg.organization_id;
      SELECT pj.NAME
        INTO p_job_name
        FROM PER_JOBS_VL pj
       WHERE pj.job_id = v_joborg.job_id
         AND rownum < 2;
      --job needn't update
      IF v_job_count = 0 THEN
        SELECT eng_ecn_approval_lists_s.nextval INTO p_list_id FROM dual;
        p_rowid := NULL;
        output('Insert Job:' || p_job_name);
        ENG_ECN_APPROVAL_LISTS_PKG.Insert_Row(X_Rowid              => p_rowid,
                                              X_Approval_List_Id   => p_list_id,
                                              X_Approval_List_Name => p_job_name || ':' ||
                                                                      p_list_id,
                                              X_Attribute1         => WF_APPROVE_CONSTANT_PKG.SOURCE_JOBOU,
                                              X_Attribute2         => v_joborg.job_id,
                                              X_Attribute3         => v_joborg.organization_id,
                                              X_Creation_Date      => SYSDATE,
                                              X_Created_By         => fnd_global.USER_ID,
                                              X_Last_Update_Date   => SYSDATE,
                                              X_Last_Updated_By    => fnd_global.USER_ID);
      ELSE
        p_rowid             := NULL;
        p_list_id           := NULL;
        p_old_disabled_date := NULL;
        p_disabled_date     := NULL;
        SELECT ROWID, eea.approval_list_id, eea.disable_date
          INTO p_rowid, p_list_id, p_old_disabled_date
          FROM eng_ecn_approval_lists eea
         WHERE eea.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_JOBOU
           AND eea.attribute2 = v_joborg.job_id
           AND eea.attribute3 = v_joborg.organization_id;
      END IF;
    
      v_per_count := 0;
      SELECT nvl(COUNT(1), 0)
        INTO v_per_count
        FROM eng_ecn_approvers eep
       WHERE eep.approval_list_id = p_list_id
         AND eep.employee_id = v_joborg.person_id;
    
      IF v_per_count = 0 THEN
        output('                  Insert person:' || v_joborg.person_id);
        p_rowid := NULL;
        ENG_ECN_APPROVERS_PKG.Insert_Row(X_Rowid            => p_rowid,
                                         X_Approval_List_Id => p_list_id,
                                         X_Employee_Id      => v_joborg.person_id,
                                         X_Sequence1        => p_index,
                                         X_Creation_Date    => SYSDATE,
                                         X_Created_By       => fnd_global.USER_ID,
                                         X_Last_Update_Date => SYSDATE,
                                         X_Last_Updated_By  => fnd_global.USER_ID);
      END IF;
      p_index := p_index + 10;
    
    END LOOP;
  
    output(fnd_global.Newline);
    p_delete_count := 0;
    output(to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss'));
    FOR v_person_delete IN c_person_delete LOOP
      ENG_ECN_APPROVERS_PKG.Delete_Row(v_person_delete.rowid);
      p_delete_count := p_delete_count + 1;
    END LOOP;
    output('                  Count of delete person ' || p_delete_count || ' !');
    p_delete_count := 0;
    FOR v_job_delete IN c_job_delete LOOP
      ENG_ECN_APPROVAL_LISTS_PKG.Delete_Row(v_job_delete.rowid);
      p_delete_count := p_delete_count + 1;
    END LOOP;
    output('                  Count of delete job ' || p_delete_count || ' !');
    output(fnd_global.Newline);
    output('End register job by ou!');
    output('*******************************************************************/');
  END;

  PROCEDURE set_new_update_date IS
    v_count NUMBER := 0;
  BEGIN
    SELECT nvl(COUNT(1), 0) INTO v_count FROM wf_approve_role_update_tl;
    IF v_count = 0 THEN
      INSERT INTO wf_approve_role_update_tl
        (last_update_date, last_update_by)
      VALUES
        (SYSDATE, fnd_global.USER_ID);
    ELSE
      UPDATE wf_approve_role_update_tl
         SET last_update_date = SYSDATE-1,
             last_update_by   = fnd_global.USER_ID;
    END IF;
  END;

  PROCEDURE register_role(errbuf  OUT NOCOPY VARCHAR2,
                          retcode OUT NOCOPY VARCHAR2) IS
  BEGIN
    
    SAVEPOINT begin_register;
    --if is_need_update_role then
    --register by position  (needn't by position and org, becase of position belong to org)
    output(to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss'));
    register_by_position;
    commit;
    output(to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss'));
    --register by job and org
    register_by_joborg;
    commit;
    output(to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss'));
    --register by job
    register_by_job;
    commit;
    output(to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss'));
    --register by job and ou
    --register_by_jobou;
    register_by_jobou_new;
    commit;
    output(to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss'));
    
  set_new_update_date;
    --end if;
  EXCEPTION
    WHEN OTHERS THEN
    
      retcode := '2';
      errbuf  := 'Error for register role, please see out put for detail message !';
      output('Code = ' || SQLCODE || ',' || ' Error Message=' ||
             substr(SQLERRM, 1, 255));
      db_output('Code = ' || SQLCODE || ',' || ' Error Message=' ||
                substr(SQLERRM, 1, 255));
      ROLLBACK TO begin_register;
  END;
  procedure add_one_by_one(p_organization_id number,
                           p_job_id          number,
                           p_person_id       number) is
    v_job_count   number;
    p_job_name    varchar2(200);
    p_list_id     number;
    v_per_count   number;
    p_person_name varchar2(200);
    p_rowid       varchar2(200);
    p_index       number := 10;
  begin
    v_job_count := 0;
    ----------------------------------------------joborg--------------------------------------------------
    SELECT nvl(COUNT(1), 0)
      INTO v_job_count
      FROM eng_ecn_approval_lists eeal
     WHERE 1 = 1
       AND eeal.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_JOBORG
       AND eeal.attribute2 = p_job_id
       AND eeal.attribute3 = p_organization_id;
    SELECT pj.NAME
      INTO p_job_name
      FROM PER_JOBS_VL pj
     WHERE pj.job_id = p_job_id
       AND rownum < 2;
    --job needn't update
   -- IF v_job_count = 0 THEN
   begin 
     SELECT eea.approval_list_id
        INTO p_list_id
        FROM eng_ecn_approval_lists eea
       WHERE eea.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_JOBORG
         AND eea.attribute2 = p_job_id
         AND eea.attribute3 = p_organization_id;
         exception when no_data_found then
      SELECT eng_ecn_approval_lists_s.nextval INTO p_list_id FROM dual;
      
      end;
      
      p_rowid := NULL;
      dbms_output.put_line('Insert Job:' || p_job_name);
      ENG_ECN_APPROVAL_LISTS_PKG.Insert_Row(X_Rowid              => p_rowid,
                                            X_Approval_List_Id   => p_list_id,
                                            X_Approval_List_Name => p_job_name || ':' ||
                                                                    p_list_id,
                                            X_Attribute1         => WF_APPROVE_CONSTANT_PKG.SOURCE_JOBORG,
                                            X_Attribute2         => p_job_id,
                                            X_Attribute3         => p_organization_id,
                                            X_Creation_Date      => SYSDATE,
                                            X_Created_By         => fnd_global.USER_ID,
                                            X_Last_Update_Date   => SYSDATE,
                                            X_Last_Updated_By    => fnd_global.USER_ID);
    --else
      
   -- end if;
  
    v_per_count := 0;
    SELECT nvl(COUNT(1), 0)
      INTO v_per_count
      FROM eng_ecn_approvers eep
     WHERE eep.approval_list_id = p_list_id
       AND eep.employee_id = p_person_id;
  
    SELECT ppf.LAST_NAME
      INTO p_person_name
      FROM PER_PEOPLE_F ppf
     WHERE 1 = 1
       AND ppf.PERSON_ID = p_person_id
       AND rownum < 2;
  
    --IF v_per_count = 0 THEN
    
      dbms_output.put_line('Insert person:' || p_person_name);
      p_rowid := NULL;
      ENG_ECN_APPROVERS_PKG.Insert_Row(X_Rowid            => p_rowid,
                                       X_Approval_List_Id => p_list_id,
                                       X_Employee_Id      => p_person_id,
                                       X_Sequence1        => p_index,
                                       X_Creation_Date    => SYSDATE,
                                       X_Created_By       => fnd_global.USER_ID,
                                       X_Last_Update_Date => SYSDATE,
                                       X_Last_Updated_By  => fnd_global.USER_ID);
   -- END IF;
  
    -------------------------------------------end joborg--------------------------------------------------
  
    -------------------------------------------job---------------------------------------------------------
    v_job_count := 0;
    SELECT nvl(COUNT(1), 0)
      INTO v_job_count
      FROM eng_ecn_approval_lists eeal
     WHERE 1 = 1
       AND eeal.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_JOB
       AND eeal.attribute2 = p_job_id;
    SELECT pj.NAME
      INTO p_job_name
      FROM PER_JOBS_VL pj
     WHERE pj.job_id = p_job_id
       AND rownum < 2;
    --IF v_job_count = 0 THEN
    begin
      SELECT eea.approval_list_id
        INTO p_list_id
        FROM eng_ecn_approval_lists eea
       WHERE eea.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_JOB
         AND eea.attribute2 = p_job_id;
       exception   when no_data_found then
      SELECT eng_ecn_approval_lists_s.nextval INTO p_list_id FROM dual;
      end;
      p_rowid := NULL;
      output('Insert Job:' || p_job_name);
      ENG_ECN_APPROVAL_LISTS_PKG.Insert_Row(X_Rowid              => p_rowid,
                                            X_Approval_List_Id   => p_list_id,
                                            X_Approval_List_Name => p_job_name || ':' ||
                                                                    p_list_id,
                                            X_Attribute1         => WF_APPROVE_CONSTANT_PKG.SOURCE_JOB,
                                            X_Attribute2         => p_job_id,
                                            X_Creation_Date      => SYSDATE,
                                            X_Created_By         => fnd_global.USER_ID,
                                            X_Last_Update_Date   => SYSDATE,
                                            X_Last_Updated_By    => fnd_global.USER_ID);
    --else
      
    --end if;
  
    SELECT nvl(COUNT(1), 0)
      INTO v_per_count
      FROM eng_ecn_approvers eep
     WHERE eep.approval_list_id = p_list_id
       AND eep.employee_id = p_person_id;
    SELECT ppf.LAST_NAME
      INTO p_person_name
      FROM PER_PEOPLE_F ppf
     WHERE 1 = 1
       AND ppf.PERSON_ID = p_person_id
       AND rownum < 2;
  
    --if v_per_count = 0 then
      p_rowid := NULL;
      ENG_ECN_APPROVERS_PKG.Insert_Row(X_Rowid            => p_rowid,
                                       X_Approval_List_Id => p_list_id,
                                       X_Employee_Id      => p_person_id,
                                       X_Sequence1        => p_index,
                                       X_Creation_Date    => SYSDATE,
                                       X_Created_By       => fnd_global.USER_ID,
                                       X_Last_Update_Date => SYSDATE,
                                       X_Last_Updated_By  => fnd_global.USER_ID);
    --end if;
  
    --------------------------------------------------end job---------------------------------------
  
    --------------------------------------------------jobou-----------------------------------------
    v_job_count := 0;
    SELECT nvl(COUNT(1), 0)
      INTO v_job_count
      FROM eng_ecn_approval_lists eeal
     WHERE 1 = 1
       AND eeal.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_JOBOU
       AND eeal.attribute2 = p_job_id
       AND eeal.attribute3 = p_organization_id;
    SELECT pj.NAME
      INTO p_job_name
      FROM PER_JOBS_VL pj
     WHERE pj.job_id = p_job_id
       AND rownum < 2;
    --job needn't update
   -- IF v_job_count = 0 THEN
   begin
     p_rowid   := NULL;
      p_list_id := NULL;
      SELECT eea.approval_list_id
        INTO p_list_id
        FROM eng_ecn_approval_lists eea
       WHERE eea.attribute1 = WF_APPROVE_CONSTANT_PKG.SOURCE_JOBOU
         AND eea.attribute2 = p_job_id
         AND eea.attribute3 = p_organization_id;
         exception when no_data_found then
      SELECT eng_ecn_approval_lists_s.nextval INTO p_list_id FROM dual;
      end;
      p_rowid := NULL;
      output('Insert Job:' || p_job_name);
      ENG_ECN_APPROVAL_LISTS_PKG.Insert_Row(X_Rowid              => p_rowid,
                                            X_Approval_List_Id   => p_list_id,
                                            X_Approval_List_Name => p_job_name || ':' ||
                                                                    p_list_id,
                                            X_Attribute1         => WF_APPROVE_CONSTANT_PKG.SOURCE_JOBOU,
                                            X_Attribute2         => p_job_id,
                                            X_Attribute3         => p_organization_id,
                                            X_Creation_Date      => SYSDATE,
                                            X_Created_By         => fnd_global.USER_ID,
                                            X_Last_Update_Date   => SYSDATE,
                                            X_Last_Updated_By    => fnd_global.USER_ID);
   -- ELSE
      
  --  END IF;
  
    SELECT nvl(COUNT(1), 0)
      INTO v_per_count
      FROM eng_ecn_approvers eep
     WHERE eep.approval_list_id = p_list_id
       AND eep.employee_id = p_person_id;
    --if v_per_count = 0 then
      ENG_ECN_APPROVERS_PKG.Insert_Row(X_Rowid            => p_rowid,
                                       X_Approval_List_Id => p_list_id,
                                       X_Employee_Id      => p_person_id,
                                       X_Sequence1        => p_index,
                                       X_Creation_Date    => SYSDATE,
                                       X_Created_By       => fnd_global.USER_ID,
                                       X_Last_Update_Date => SYSDATE,
                                       X_Last_Updated_By  => fnd_global.USER_ID);
   -- end if;
  end;
BEGIN
  mo_global.init('WPC');
END wf_register_pkg;
