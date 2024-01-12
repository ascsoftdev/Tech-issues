CREATE TABLE MEMBER(member_id varchar2(20) PRIMARY KEY, 
    firstname VARCHAR(20) NOT NULL,
    lastname varchar2(20) NOT NULL,
    gender varchar2(20) NOT NULL,
    dob Date NOT NULL,
    created_at DATE NOT NULL);
	
CREATE TABLE member_history (
  member_id VARCHAR2(20),
  firstname VARCHAR(20) NOT NULL,
  lastname varchar2(20) NOT NULL,
  gender varchar2(20) NOT NULL,
  dob Date NOT NULL,
  created_at DATE NOT NULL,
  modified_date DATE,
  action_type VARCHAR2(20),
  PRIMARY KEY (member_id, modified_date)
);	


CREATE OR REPLACE TRIGGER member_audit
AFTER INSERT OR UPDATE ON member
FOR EACH ROW
DECLARE
  v_action_type VARCHAR2(10);
BEGIN
  IF INSERTING THEN
    v_action_type := 'INSERT'; 
  ELSE
    v_action_type := 'UPDATE';
  END IF;  
   
    INSERT INTO member_history (member_id,firstname,lastname,gender,dob,created_at, modified_date,action_type)
    VALUES (:NEW.member_id,:NEW.firstname, :NEW.lastname, :NEW.gender,:NEW.dob, :NEW.created_at, SYSDATE,v_action_type);        
END;
/

INSERT INTO MEMBER (member_id,firstname,lastname,gender,dob,created_at) 
VALUES ('101', 'Jignesh', 'Chauhan', 'Male', to_date('01-01-1985'), SYSDATE);

UPDATE MEMBER SET lastname='Singh Chauhan' WHERE member_id = '101';

* FlashBack Data ARCHIVE Approch need to work on this



CREATE TABLE MEMBER(
    id integer PRIMARY KEY,
    member_id varchar2(20) NOT NULL UNIQUE , 
    firstname VARCHAR(20) NOT NULL,
    lastname varchar2(20) NOT NULL,
    gender varchar2(20) NOT NULL,
    dob Date NOT NULL,
    created_by varchar2(2000) DEFAULT USER NOT NULL,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    modified_by varchar2(2000),
    modified_at TIMESTAMP);
	
	
CREATE TABLE member_history (
    id integer NOT NULL,
    member_id varchar2(20) NOT NULL , 
    firstname VARCHAR(20) NOT NULL,
    lastname varchar2(20) NOT NULL,
    gender varchar2(20) NOT NULL,
    dob Date NOT NULL,
    created_by varchar2(2000) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    modified_by varchar2(2000) ,
    modified_at TIMESTAMP,
    action_type VARCHAR2(20),
    PRIMARY KEY (id, modified_at)
);

CREATE OR REPLACE TRIGGER member_audit AFTER
    INSERT OR UPDATE ON member
    FOR EACH ROW
DECLARE
    v_action_type VARCHAR2(10);
BEGIN
    IF inserting THEN
        v_action_type := 'INSERT';
    ELSE
        v_action_type := 'UPDATE';
    END IF;
    IF v_action_type <> 'INSERT' THEN
        INSERT INTO member_history (
            id,
            member_id,
            firstname,
            lastname,
            gender,
            dob,
            created_by,
            created_at,
            modified_by,
            modified_at,
            action_type
        ) VALUES (
            :old.id,
            :new.member_id,
            :new.firstname,
            :new.lastname,
            :new.gender,
            :new.dob,
            :old.created_by,
            :old.created_at,
            user,
            sysdate,
            v_action_type
        );

    ELSE
        INSERT INTO member_history (
            id,
            member_id,
            firstname,
            lastname,
            gender,
            dob,
            created_by,
            created_at,
            modified_by,
            modified_at,
            action_type
        ) VALUES (
            :new.id,
            :new.member_id,
            :new.firstname,
            :new.lastname,
            :new.gender,
            :new.dob,
            :new.created_by,
            :new.created_at,
            :new.created_by,
            :new.created_at,
            v_action_type
        );

    END IF;

END;
/

/****INSERT UPDATE DELETE***********/


CREATE OR REPLACE TRIGGER member_audit AFTER
    INSERT OR UPDATE OR DELETE ON member
    FOR EACH ROW
DECLARE
    v_action_type VARCHAR2(10);
BEGIN
    IF inserting THEN
        v_action_type := 'INSERT';
    ELSIF updating THEN
        v_action_type := 'UPDATE';
    ELSIF deleting THEN
        v_action_type := 'DELETE';
    END IF;

    IF v_action_type = 'INSERT' OR v_action_type = 'UPDATE' THEN
        INSERT INTO member_history (
            member_id,
            firstname,
            lastname,
            gender,
            dob,
            created_at,
            modified_date,
            action_type
        ) VALUES (
            :new.member_id,
            :new.firstname,
            :new.lastname,
            :new.gender,
            :new.dob,
            :new.created_at,
            sysdate,
            v_action_type
        );

    ELSE
        INSERT INTO member_history (
            member_id,
            firstname,
            lastname,
            gender,
            dob,
            created_at,
            modified_date,
            action_type
        ) VALUES (
            :old.member_id,
            :old.firstname,
            :old.lastname,
            :old.gender,
            :old.dob,
            :old.created_at,
            sysdate,
            v_action_type
        );

    END IF;

END;