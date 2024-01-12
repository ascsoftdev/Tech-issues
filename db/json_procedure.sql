create or replace PACKAGE BODY PCS_TOOL_ADULT_PKG AS 

/*************************************************************************
** PACKAGE NAME     	: PCS_TOOL_ADULT_PKG							**
**                     												  	**
** VERSION              : 1.0              							   	**
**                     												   	**
** DESCRIPTION          : procedures for pcs tool			           	**
**							                     					   	**
**                     												   	**
** AUTHOR               : CT              							   	**
** DEVELOPER            : Anil Chauhan              					**
**                     												   	**
** DATE                 : 07/05/2023									**
**																		**
** 																	   	**
** 																	   	**
** Implemented SP 														**
** 						: createPcstool									**
** 						: getpcstool									**
** 						: pcstooluser									**
** 						: 												**
** 						: 												**
**----------------------------------------------------------------------**
** CHANGE  | HISTORY    |              |   								**
** VERSION | DATE       | AUTHOR       | CHANGE DESCRIPTION            	**
**---------|------------|--------------|--------------------------------**
** 1.0     | 07/05/2023 | CT           | Initial Version               	**
*************************************************************************/

 PROCEDURE adultPcsTool(request IN CLOB, response OUT CLOB)
  AS
    filterObj   JSON_OBJECT_T   := JSON_OBJECT_T.parse(request);
    l_pcs_tool_adult_section_detail_array JSON_ARRAY_T;
    l_section_detail_obj JSON_OBJECT_T;
    l_level_value VARCHAR2(200);
    l_input_key   VARCHAR2(200);
    l_input_value VARCHAR2(200);
    l_flag_adult_section_details VARCHAR2(200);

    --COMMON Object -----------------------
    t_common_obj        JSON_OBJECT_T := filterObj.get_Object('COMMON');
    common_status       VARCHAR2(200) := t_common_obj.get_String('STATUS');
    common_flag         VARCHAR2(200) := t_common_obj.get_String('FLAG'); 
	common_username     VARCHAR2(200) := t_common_obj.get_String('USERNAME');
	common_pcs_tool_id	INTEGER := t_common_obj.get_Number('PCS_TOOL_ID');

    --PCS_TOOL_ADULT_SECTION_TBL  FIELDS----------------
    t_pcs_tool_adult_section_obj      JSON_OBJECT_T       := filterObj.get_Object('PCS_TOOL_ADULT_SECTION_TBL');    
    t_pcs_tool_adult_section_id       INTEGER             := t_pcs_tool_adult_section_obj.get_Number('PCS_TOOL_ADULT_SECTION_ID');
	t_pcs_tool_id         			INTEGER             := t_pcs_tool_adult_section_obj.get_Number('PCS_TOOL_ID');
    t_pcs_tool_section    	    				VARCHAR2(2000)      := t_pcs_tool_adult_section_obj.get_String('SECTION');
	t_total_minutes    				NUMBER              := t_pcs_tool_adult_section_obj.get_Number('TOTAL_MINUTES');
	t_needs_level    					VARCHAR2(200)       := t_pcs_tool_adult_section_obj.get_String('NEEDS_LEVEL');
	t_other_supports    				VARCHAR2(2000)      := t_pcs_tool_adult_section_obj.get_String('OTHER_SUPPORTS');
	t_enter_days_per_week    			INTEGER         	:= t_pcs_tool_adult_section_obj.get_Number('ENTER_DAYS_PER_WEEK');
	t_minutes_per_day    				INTEGER         	:= t_pcs_tool_adult_section_obj.get_Number('MINUTES_PER_DAY');
	t_days_per_week    				INTEGER         	:= t_pcs_tool_adult_section_obj.get_Number('DAYS_PER_WEEK');
    t_notes    	    				VARCHAR2(200)       := t_pcs_tool_adult_section_obj.get_String('NOTES');
    t_created_user    		    	VARCHAR2(200)       := t_pcs_tool_adult_section_obj.get_String('CREATED_USER');
	t_last_updated_user   			VARCHAR2(200)       := t_pcs_tool_adult_section_obj.get_String('LAST_UPDATED_USER');    
	t_flag_adult_section   			VARCHAR2(200)       := t_pcs_tool_adult_section_obj.get_String('FLAG_ADULT_SECTION');

    responseObj    JSON_OBJECT_T := JSON_OBJECT_T();
    error_obj      CLOB;
	l_pcs_tool_adult_section_id INTEGER;
    l_adult_id INTEGER;

	---- PCS TOOL OBJECT --------------------
	l_Care_Coordinator VARCHAR2(200);
	l_Assessment_Type VARCHAR2(200);
	l_Assessment_Date DATE;
	l_pcs_tool_flag  VARCHAR2(200);

 BEGIN
 l_pcs_tool_adult_section_detail_array := t_pcs_tool_adult_section_obj.get_Array('PCS_TOOL_ADULT_SECTION_DETAILS_TBL');
 IF common_flag = 'CREATE' THEN

    INSERT INTO PCS_TOOL.PCS_TOOL_ADULT_SECTION_TBL (
        PCS_TOOL_ID,
        SECTION,
        TOTAL_MINUTES,
        NEEDS_LEVEL,
        OTHER_SUPPORTS,
        ENTER_DAYS_PER_WEEK,
        MINUTES_PER_DAY,
        DAYS_PER_WEEK,
        NOTES,
        CREATED_USER,
		CREATED_DATE,
        LAST_UPDATED_USER,
		LAST_UPDATED_DATE
        ) VALUES (
        common_pcs_tool_id,
        t_pcs_tool_section,
        t_total_minutes,
		t_needs_level,
		t_other_supports,
		t_enter_days_per_week,
		t_minutes_per_day,
		t_days_per_week,
		t_notes,
		common_username,
		SYSDATE,
		t_last_updated_user,
		SYSDATE
        )
        RETURNING PCS_TOOL_ADULT_SECTION_ID INTO l_pcs_tool_adult_section_id; 

    FOR i IN 0..l_pcs_tool_adult_section_detail_array.get_size() - 1
    LOOP
        l_section_detail_obj := JSON_OBJECT_T(l_pcs_tool_adult_section_detail_array.get(i));
        l_level_value := l_section_detail_obj.get_String('LEVEL');
        l_input_key := l_section_detail_obj.get_String('INPUT_KEY');
        l_input_value := l_section_detail_obj.get_String('VALUE');

        INSERT INTO PCS_TOOL_ADULT_SECTION_DETAILS_TBL (
        PCS_TOOL_ADULT_SECTION_ID,
        LEVEL_VALUE,
        INPUT_KEY,
        INPUT_VALUE
        ) VALUES (
        l_pcs_tool_adult_section_id,
        l_level_value,
        l_input_key,
        l_input_value
        );

    END LOOP;

	l_pcs_tool_flag := l_pcs_tool.get_String('FLAG');

	IF l_pcs_tool_flag = 'CREATE' THEN
		l_Care_Coordinator := l_pcs_tool.get_String('CARE_COORDINATOR');
		l_Assessment_Type := l_pcs_tool.get_String('ASSESSMENT_TYPE');
		l_Assessment_Date := TO_DATE(l_pcs_tool.get_String('ASSESSMENT_DATE'), 'MM/dd/YYYY');

		UPDATE PCS_TOOL.PCS_TOOL_TBL 
		SET care_coordinator = l_Care_Coordinator,
		assessment_type = l_Assessment_Type,
		assessment_date = l_Assessment_Date
		WHERE PCS_TOOL_ID = common_pcs_tool_id;

	END IF;

	UPDATE PCS_TOOL.PCS_TOOL_TBL 
	SET LAST_UPDATED_USER = t_last_updated_user,
	last_updated_date = SYSDATE
	WHERE PCS_TOOL_ID = common_pcs_tool_id;

	UPDATE PCS_TOOL.PCS_TOOL_EPSDT_SECTION_TBL 
	SET LAST_UPDATED_USER = t_last_updated_user,
	last_updated_date = SYSDATE
	WHERE PCS_TOOL_ID = common_pcs_tool_id;

	COMMIT;

    SELECT
        JSON_OBJECT(
            KEY 'STATUS' VALUE 'SUCCESS'                  
            RETURNING CLOB
            )
    INTO response
    FROM DUAL; 
END IF;

ELSIF  common_flag = 'UPDATE' THEN        
    IF t_flag_adult_section = 'UPDATE' THEN
        UPDATE PCS_TOOL.PCS_TOOL_ADULT_SECTION_TBL SET
            pcs_tool_id = t_pcs_tool_id,
            section = t_pcs_tool_section,
            total_minutes = t_total_minutes,
            needs_level = t_needs_level,
            other_supports = t_other_supports,
            enter_days_per_week = t_enter_days_per_week,
            minutes_per_day = t_minutes_per_day,
            days_per_week = t_days_per_week,
            notes = t_notes,
            last_updated_user = t_last_updated_user
        WHERE pcs_tool_adult_section_id = t_pcs_tool_adult_section_id; 
    END IF;

    l_pcs_tool_flag := l_pcs_tool.get_String('FLAG');

	IF l_pcs_tool_flag = 'UPDATE' THEN
		l_Care_Coordinator := l_pcs_tool.get_String('CARE_COORDINATOR');
		l_Assessment_Type := l_pcs_tool.get_String('ASSESSMENT_TYPE');
		l_Assessment_Date := TO_DATE(l_pcs_tool.get_String('ASSESSMENT_DATE'), 'MM/dd/YYYY');

		UPDATE PCS_TOOL.PCS_TOOL_TBL 
		SET care_coordinator = l_Care_Coordinator,
		assessment_type = l_Assessment_Type,
		assessment_date = l_Assessment_Date
		WHERE PCS_TOOL_ID = common_pcs_tool_id;

	END IF;

		UPDATE PCS_TOOL.PCS_TOOL_TBL 
		SET LAST_UPDATED_USER = t_last_updated_user,
		last_updated_date = SYSDATE
		WHERE PCS_TOOL_ID = common_pcs_tool_id;

		UPDATE PCS_TOOL.PCS_TOOL_EPSDT_SECTION_TBL 
		SET LAST_UPDATED_USER = t_last_updated_user,
		last_updated_date = SYSDATE
		WHERE PCS_TOOL_ID = common_pcs_tool_id;

		COMMIT;

		SELECT
			JSON_OBJECT(
				KEY 'STATUS' VALUE 'SUCCESS'                  
				RETURNING CLOB
				)
		INTO response
		FROM DUAL; 
END IF;

	EXCEPTION 
    WHEN OTHERS THEN          
        t_common_obj.put('STATUS', 'FAILURE');        
        error_obj := handle_exception(SQLCODE, SQLERRM);
        t_common_obj.put('errors', JSON_OBJECT_T.parse(error_obj));
		responseObj.put('COMMON',t_common_obj);
        response := responseObj.to_String;

END adultPcsTool;

 ----------------------------- GET ADULT PCS TOOL ---------------------------------------------------

 PROCEDURE getAdultPcsTool(request IN CLOB, response OUT CLOB)
  AS
    filterObj   JSON_OBJECT_T   := JSON_OBJECT_T.parse(request);
	l_flag_adult_section_details VARCHAR2(200);    

    --COMMON Object -----------------------
    t_common_obj        JSON_OBJECT_T := filterObj.get_Object('COMMON');
    common_status       VARCHAR2(200) := t_common_obj.get_String('STATUS');
    common_flag         VARCHAR2(200) := t_common_obj.get_String('FLAG'); 
	common_username     VARCHAR2(200) := t_common_obj.get_String('USERNAME');
	common_pcs_tool_id	VARCHAR2(200) := t_common_obj.get_Number('PCS_TOOL_ID');
	common_section	VARCHAR2(200) := t_common_obj.get_String('SECTION');          

	--PCS_TOOL_ADULT_SECTION_TBL  FIELDS----------------
    t_pcs_tool_adult_section_obj    JSON_OBJECT_T       := filterObj.get_Object('PCS_TOOL_ADULT_SECTION_TBL');    
    t_pcs_tool_adult_section_id     INTEGER             := t_pcs_tool_adult_section_obj.get_Number('PCS_TOOL_ADULT_SECTION_ID');
	t_pcs_tool_id         			INTEGER             := t_pcs_tool_adult_section_obj.get_Number('PCS_TOOL_ID');
    t_pcs_tool_section    	    	VARCHAR2(2000)      := t_pcs_tool_adult_section_obj.get_String('SECTION');
	t_total_minutes    				NUMBER              := t_pcs_tool_adult_section_obj.get_Number('TOTAL_MINUTES');
	t_needs_level    				VARCHAR2(200)       := t_pcs_tool_adult_section_obj.get_String('NEEDS_LEVEL');
	t_other_supports    			VARCHAR2(2000)      := t_pcs_tool_adult_section_obj.get_String('OTHER_SUPPORTS');
	t_enter_days_per_week    		INTEGER         	:= t_pcs_tool_adult_section_obj.get_Number('ENTER_DAYS_PER_WEEK');
	t_minutes_per_day    			INTEGER         	:= t_pcs_tool_adult_section_obj.get_Number('MINUTES_PER_DAY');
	t_days_per_week    				INTEGER         	:= t_pcs_tool_adult_section_obj.get_Number('DAYS_PER_WEEK');
    t_notes    	    				VARCHAR2(200)       := t_pcs_tool_adult_section_obj.get_String('NOTES');
    t_created_user    		    	VARCHAR2(200)       := t_pcs_tool_adult_section_obj.get_String('CREATED_USER');
	t_last_updated_user   			VARCHAR2(200)       := t_pcs_tool_adult_section_obj.get_String('LAST_UPDATED_USER');    
	t_flag_adult_section   			VARCHAR2(200)       := t_pcs_tool_adult_section_obj.get_String('FLAG_ADULT_SECTION');

    error_obj      CLOB;
    error_response JSON_OBJECT_T := JSON_OBJECT_T();	

 BEGIN                

    select 
		JSON_OBJECT(
	key  'COMMON' value JSON_OBJECT(
			key  'STATUS' value 'SUCCESS',
			key 'FLAG' value common_flag,
			key 'PCS_TOOL_ID' value common_pcs_tool_id
		),
	key  'PCS_TOOL_ADULT_SECTION_TBL' value (
			select JSON_OBJECT(
			key 'PCS_TOOL_ADULT_SECTION_ID' value pcs_tool_adult_section_id,
			key 'PCS_TOOL_ID' value pcs_tool_id,
			key 'SECTION' value section,
			key 'TOTAL_MINUTES' value total_minutes,
			key 'NEEDS_LEVEL' value needs_level,
			key 'OTHER_SUPPORTS' value other_supports,
			key 'ENTER_DAYS_PER_WEEK' value enter_days_per_week,
			key 'MINUTES_PER_DAY' value minutes_per_day,
			key 'DAYS_PER_WEEK' value days_per_week,
			key 'NOTES' value notes,
			key 'CREATED_USER' value created_date,
			key 'LAST_UPDATED_USER' value ''))
		),
	key 'PCS_TOOL_ADULT_SECTION_DETAILS_TBL' value (
        select JSON_ARRAYAGG(
        JSON_OBJECT(
            key 'PCS_TOOL_ADULT_SECTION_DETAILS_ID' value dt.pcs_tool_adult_section_details_id,
            key 'PCS_TOOL_ADULT_SECTION_ID' value dt.pcs_tool_adult_section_id,
            key 'LEVEL' value dt.level_value,
            key 'INPUT_KEY' value dt.input_key,
            key 'VALUE' value dt.input_value,
            key 'FLAG_ADULT_SECTION' value dt.flag_adult_section
			))
        FROM pcs_tool_adult_section_details_tbl dt WHERE dt.pcs_tool_adult_section_id = ad.pcs_tool_adult_section_id
			)   
    ) INTO response

	from pcs_tool_adult_section_tbl ad where ad.pcs_tool_id = common_pcs_tool_id and ad.section = common_section;

	COMMIT;

    EXCEPTION 
    WHEN OTHERS THEN               
		t_common_obj.put('STATUS', 'FAILURE');               
        error_obj := handle_exception(SQLCODE, SQLERRM);
        t_common_obj.put('ERRORS', JSON_OBJECT_T.parse(error_obj)); 
		error_response.put('COMMON', t_common_obj);	
        response := error_response.to_String;
       -- DBMS_OUTPUT.PUT_LINE(response);

 END getAdultPcsTool;

END PCS_TOOL_ADULT_PKG;