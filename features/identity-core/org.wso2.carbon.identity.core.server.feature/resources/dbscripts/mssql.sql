IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_BASE_TABLE]') AND TYPE IN (N'U'))
CREATE TABLE IDN_BASE_TABLE (
            PRODUCT_NAME VARCHAR(20),
            PRIMARY KEY (PRODUCT_NAME)
);

INSERT INTO IDN_BASE_TABLE values ('WSO2 Identity Server');

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_OAUTH_CONSUMER_APPS]') AND TYPE IN (N'U'))
CREATE TABLE IDN_OAUTH_CONSUMER_APPS (
            ID INTEGER IDENTITY,
            CONSUMER_KEY VARCHAR(255),
            CONSUMER_SECRET VARCHAR(512),
            USERNAME VARCHAR(255),
            TENANT_ID INTEGER DEFAULT 0,
            USER_DOMAIN VARCHAR(50),
            APP_NAME VARCHAR(255),
            OAUTH_VERSION VARCHAR(128),
            CALLBACK_URL VARCHAR(1024),
            GRANT_TYPES VARCHAR(1024),
            PKCE_MANDATORY CHAR(1) DEFAULT '0',
            PKCE_SUPPORT_PLAIN CHAR(1) DEFAULT '0',
            APP_STATE VARCHAR (25) DEFAULT 'ACTIVE',
            CONSTRAINT CONSUMER_KEY_CONSTRAINT UNIQUE (CONSUMER_KEY),
            PRIMARY KEY (ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_OAUTH1A_REQUEST_TOKEN]') AND TYPE IN (N'U'))
CREATE TABLE IDN_OAUTH1A_REQUEST_TOKEN (
            REQUEST_TOKEN VARCHAR(512),
            REQUEST_TOKEN_SECRET VARCHAR(512),
            CONSUMER_KEY_ID INTEGER,
            CALLBACK_URL VARCHAR(1024),
            SCOPE VARCHAR(2048),
            AUTHORIZED VARCHAR(128),
            OAUTH_VERIFIER VARCHAR(512),
            AUTHZ_USER VARCHAR(512),
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (REQUEST_TOKEN),
            FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_OAUTH1A_ACCESS_TOKEN]') AND TYPE IN (N'U'))
CREATE TABLE IDN_OAUTH1A_ACCESS_TOKEN (
            ACCESS_TOKEN VARCHAR(512),
            ACCESS_TOKEN_SECRET VARCHAR(512),
            CONSUMER_KEY_ID INTEGER,
            SCOPE VARCHAR(2048),
            AUTHZ_USER VARCHAR(512),
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (ACCESS_TOKEN),
            FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_OAUTH2_ACCESS_TOKEN]') AND TYPE IN (N'U'))
CREATE TABLE IDN_OAUTH2_ACCESS_TOKEN (
            TOKEN_ID VARCHAR (255),
            ACCESS_TOKEN VARCHAR(255),
            REFRESH_TOKEN VARCHAR(255),
            CONSUMER_KEY_ID INTEGER,
            AUTHZ_USER VARCHAR (100),
            TENANT_ID INTEGER,
            USER_DOMAIN VARCHAR(50),
            USER_TYPE VARCHAR (25),
            GRANT_TYPE VARCHAR (50),
            TIME_CREATED DATETIME,
            REFRESH_TOKEN_TIME_CREATED DATETIME,
            VALIDITY_PERIOD BIGINT,
            REFRESH_TOKEN_VALIDITY_PERIOD BIGINT,
            TOKEN_SCOPE_HASH VARCHAR(32),
            TOKEN_STATE VARCHAR(25) DEFAULT 'ACTIVE',
            TOKEN_STATE_ID VARCHAR (128) DEFAULT 'NONE',
            SUBJECT_IDENTIFIER VARCHAR(255),
            PRIMARY KEY (TOKEN_ID),
            FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE,
            CONSTRAINT CON_APP_KEY UNIQUE (CONSUMER_KEY_ID,AUTHZ_USER,TENANT_ID,USER_DOMAIN,USER_TYPE,TOKEN_SCOPE_HASH,
                                           TOKEN_STATE,TOKEN_STATE_ID)
);

CREATE INDEX IDX_AT_CK_AU ON IDN_OAUTH2_ACCESS_TOKEN(CONSUMER_KEY_ID, AUTHZ_USER, TOKEN_STATE, USER_TYPE);

CREATE INDEX IDX_TC ON IDN_OAUTH2_ACCESS_TOKEN(TIME_CREATED);

CREATE INDEX IDX_AT ON IDN_OAUTH2_ACCESS_TOKEN(ACCESS_TOKEN);

IF EXISTS (SELECT NAME FROM SYSINDEXES WHERE NAME = 'IDX_AT_CK_AU')
DROP INDEX IDN_OAUTH2_ACCESS_TOKEN.IDX_AT_CK_AU

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_OAUTH2_AUTHORIZATION_CODE]') AND TYPE IN (N'U'))
CREATE TABLE IDN_OAUTH2_AUTHORIZATION_CODE (
            CODE_ID VARCHAR (255),
            AUTHORIZATION_CODE VARCHAR(512),
            CONSUMER_KEY_ID INTEGER,
	          CALLBACK_URL VARCHAR(1024),
            SCOPE VARCHAR(2048),
            AUTHZ_USER VARCHAR (100),
            TENANT_ID INTEGER,
            USER_DOMAIN VARCHAR(50),
            TIME_CREATED DATETIME,
            VALIDITY_PERIOD BIGINT,
            STATE VARCHAR (25) DEFAULT 'ACTIVE',
            TOKEN_ID VARCHAR(255),
            SUBJECT_IDENTIFIER VARCHAR(255),
            PKCE_CODE_CHALLENGE VARCHAR (255),
            PKCE_CODE_CHALLENGE_METHOD VARCHAR(128),
            PRIMARY KEY (CODE_ID),
            FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE
);

CREATE INDEX IDX_AUTHORIZATION_CODE ON IDN_OAUTH2_AUTHORIZATION_CODE (AUTHORIZATION_CODE,CONSUMER_KEY_ID);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_OAUTH2_ACCESS_TOKEN_SCOPE]') AND TYPE IN (N'U'))
CREATE TABLE IDN_OAUTH2_ACCESS_TOKEN_SCOPE (
            TOKEN_ID VARCHAR (255),
            TOKEN_SCOPE VARCHAR (2048),
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (TOKEN_ID, TOKEN_SCOPE),
            FOREIGN KEY (TOKEN_ID) REFERENCES IDN_OAUTH2_ACCESS_TOKEN(TOKEN_ID) ON DELETE CASCADE
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_OAUTH2_SCOPE]') AND TYPE IN (N'U'))
CREATE TABLE IDN_OAUTH2_SCOPE (
  			SCOPE_ID INTEGER IDENTITY,
  			SCOPE_KEY VARCHAR(100) NOT NULL,
  			NAME VARCHAR(255) NULL,
  			DESCRIPTION VARCHAR(512) NULL,
  			TENANT_ID INTEGER NOT NULL DEFAULT 0,
			ROLES VARCHAR (500) NULL,
  			PRIMARY KEY (SCOPE_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_OAUTH2_RESOURCE_SCOPE]') AND TYPE IN (N'U'))
CREATE TABLE IDN_OAUTH2_RESOURCE_SCOPE (
  			RESOURCE_PATH VARCHAR(255) NOT NULL,
  			SCOPE_ID INTEGER NOT NULL,
  			TENANT_ID INTEGER DEFAULT -1,
  			PRIMARY KEY (RESOURCE_PATH),
  			FOREIGN KEY (SCOPE_ID) REFERENCES IDN_OAUTH2_SCOPE (SCOPE_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_SCIM_GROUP]') AND TYPE IN (N'U'))
CREATE TABLE IDN_SCIM_GROUP (
            ID INTEGER IDENTITY,
            TENANT_ID INTEGER NOT NULL,
            ROLE_NAME VARCHAR(255) NOT NULL,
            ATTR_NAME VARCHAR(1024) NOT NULL,
            ATTR_VALUE VARCHAR(1024),
            PRIMARY KEY (ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_OPENID_REMEMBER_ME]') AND TYPE IN (N'U'))
CREATE TABLE IDN_OPENID_REMEMBER_ME (
            USER_NAME VARCHAR(255) NOT NULL,
            TENANT_ID INTEGER DEFAULT 0,
            COOKIE_VALUE VARCHAR(1024),
            CREATED_TIME DATETIME,
            PRIMARY KEY (USER_NAME, TENANT_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_OPENID_USER_RPS]') AND TYPE IN (N'U'))
CREATE TABLE IDN_OPENID_USER_RPS (
			USER_NAME VARCHAR(255) NOT NULL,
			TENANT_ID INTEGER DEFAULT 0,
			RP_URL VARCHAR(255) NOT NULL,
			TRUSTED_ALWAYS VARCHAR(128) DEFAULT 'FALSE',
			LAST_VISIT DATE NOT NULL,
			VISIT_COUNT INTEGER DEFAULT 0,
			DEFAULT_PROFILE_NAME VARCHAR(255) DEFAULT 'DEFAULT',
			PRIMARY KEY (USER_NAME, TENANT_ID, RP_URL)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_OPENID_ASSOCIATIONS]') AND TYPE IN (N'U'))
CREATE TABLE IDN_OPENID_ASSOCIATIONS (
			HANDLE VARCHAR(255) NOT NULL,
			ASSOC_TYPE VARCHAR(255) NOT NULL,
			EXPIRE_IN DATETIME NOT NULL,
			MAC_KEY VARCHAR(255) NOT NULL,
			ASSOC_STORE VARCHAR(128) DEFAULT 'SHARED',
			TENANT_ID INTEGER DEFAULT -1,
			PRIMARY KEY (HANDLE)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_STS_STORE]') AND TYPE IN (N'U'))
CREATE TABLE IDN_STS_STORE (
            ID INTEGER IDENTITY,
            TOKEN_ID VARCHAR(255) NOT NULL,
            TOKEN_CONTENT VARBINARY(MAX) NOT NULL,
            CREATE_DATE DATETIME NOT NULL,
            EXPIRE_DATE DATETIME NOT NULL,
            STATE INTEGER DEFAULT 0,
            PRIMARY KEY (ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_IDENTITY_USER_DATA]') AND TYPE IN (N'U'))
CREATE TABLE IDN_IDENTITY_USER_DATA (
            TENANT_ID INTEGER DEFAULT -1234,
            USER_NAME VARCHAR(255) NOT NULL,
            DATA_KEY VARCHAR(255) NOT NULL,
            DATA_VALUE VARCHAR(255),
            PRIMARY KEY (TENANT_ID, USER_NAME, DATA_KEY)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_IDENTITY_META_DATA]') AND TYPE IN (N'U'))
CREATE TABLE IDN_IDENTITY_META_DATA (
            USER_NAME VARCHAR(255) NOT NULL,
            TENANT_ID INTEGER DEFAULT -1234,
            METADATA_TYPE VARCHAR(255) NOT NULL,
            METADATA VARCHAR(255) NOT NULL,
            VALID VARCHAR(255) NOT NULL,
            PRIMARY KEY (TENANT_ID, USER_NAME, METADATA_TYPE,METADATA)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_THRIFT_SESSION]') AND TYPE IN (N'U'))
CREATE TABLE IDN_THRIFT_SESSION (
       		SESSION_ID VARCHAR(255) NOT NULL,
       		USER_NAME VARCHAR(255) NOT NULL,
       		CREATED_TIME VARCHAR(255) NOT NULL,
       		LAST_MODIFIED_TIME VARCHAR(255) NOT NULL,
       		TENANT_ID INTEGER DEFAULT -1,
       		PRIMARY KEY (SESSION_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_AUTH_SESSION_STORE]') AND TYPE IN (N'U'))
CREATE TABLE IDN_AUTH_SESSION_STORE (
        SESSION_ID VARCHAR (100) NOT NULL,
        SESSION_TYPE VARCHAR(100) NOT NULL,
        OPERATION VARCHAR(10) NOT NULL,
        SESSION_OBJECT VARBINARY(MAX),
        TIME_CREATED BIGINT,
        TENANT_ID INTEGER DEFAULT -1,
        PRIMARY KEY (SESSION_ID, SESSION_TYPE, TIME_CREATED, OPERATION)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[SP_APP]') AND TYPE IN (N'U'))
CREATE TABLE SP_APP (
        ID INTEGER NOT NULL IDENTITY,
        TENANT_ID INTEGER NOT NULL,
	    	APP_NAME VARCHAR (255) NOT NULL ,
	    	USER_STORE VARCHAR (255) NOT NULL,
        USERNAME VARCHAR (255) NOT NULL ,
        DESCRIPTION VARCHAR (1024),
	    	ROLE_CLAIM VARCHAR (512),
        AUTH_TYPE VARCHAR (255) NOT NULL,
	    	PROVISIONING_USERSTORE_DOMAIN VARCHAR (512),
	    	IS_LOCAL_CLAIM_DIALECT CHAR(1) DEFAULT '1',
	    	IS_SEND_LOCAL_SUBJECT_ID CHAR(1) DEFAULT '0',
	    	IS_SEND_AUTH_LIST_OF_IDPS CHAR(1) DEFAULT '0',
        IS_USE_TENANT_DOMAIN_SUBJECT CHAR(1) DEFAULT '1',
        IS_USE_USER_DOMAIN_SUBJECT CHAR(1) DEFAULT '1',
        ENABLE_AUTHORIZATION CHAR(1) DEFAULT '0',
	    	SUBJECT_CLAIM_URI VARCHAR (512),
	    	IS_SAAS_APP CHAR(1) DEFAULT '0',
	    	IS_DUMB_MODE CHAR(1) DEFAULT '0',
        PRIMARY KEY (ID));

ALTER TABLE SP_APP ADD CONSTRAINT APPLICATION_NAME_CONSTRAINT UNIQUE(APP_NAME, TENANT_ID);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[SP_METADATA]') AND TYPE IN (N'U'))
CREATE TABLE SP_METADATA (
            ID INTEGER IDENTITY,
            SP_ID INTEGER,
            NAME VARCHAR(255) NOT NULL,
            VALUE VARCHAR(255) NOT NULL,
            DISPLAY_NAME VARCHAR(255),
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (ID),
            CONSTRAINT SP_METADATA_CONSTRAINT UNIQUE (SP_ID, NAME),
            FOREIGN KEY (SP_ID) REFERENCES SP_APP(ID) ON DELETE CASCADE);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[SP_INBOUND_AUTH]') AND TYPE IN (N'U'))
CREATE TABLE SP_INBOUND_AUTH (
            ID INTEGER NOT NULL IDENTITY,
            TENANT_ID INTEGER NOT NULL,
            INBOUND_AUTH_KEY VARCHAR (255),
            INBOUND_AUTH_TYPE VARCHAR (255) NOT NULL,
            INBOUND_CONFIG_TYPE VARCHAR (255) NOT NULL,
            PROP_NAME VARCHAR (255),
            PROP_VALUE VARCHAR (1024) ,
       	    APP_ID INTEGER NOT NULL,
            PRIMARY KEY (ID));

ALTER TABLE SP_INBOUND_AUTH ADD CONSTRAINT APPLICATION_ID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[SP_AUTH_STEP]') AND TYPE IN (N'U'))
CREATE TABLE SP_AUTH_STEP (
            ID INTEGER NOT NULL IDENTITY,
            TENANT_ID INTEGER NOT NULL,
       	    STEP_ORDER INTEGER DEFAULT 1,
            APP_ID INTEGER NOT NULL,
            IS_SUBJECT_STEP CHAR(1) DEFAULT '0',
            IS_ATTRIBUTE_STEP CHAR(1) DEFAULT '0',
            PRIMARY KEY (ID));

ALTER TABLE SP_AUTH_STEP ADD CONSTRAINT APPLICATION_ID_CONSTRAINT_STEP FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[SP_FEDERATED_IDP]') AND TYPE IN (N'U'))
CREATE TABLE SP_FEDERATED_IDP (
            ID INTEGER NOT NULL,
            TENANT_ID INTEGER NOT NULL,
            AUTHENTICATOR_ID INTEGER NOT NULL,
            PRIMARY KEY (ID, AUTHENTICATOR_ID));

ALTER TABLE SP_FEDERATED_IDP ADD CONSTRAINT STEP_ID_CONSTRAINT FOREIGN KEY (ID) REFERENCES SP_AUTH_STEP (ID) ON DELETE CASCADE;

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[SP_CLAIM_MAPPING]') AND TYPE IN (N'U'))
CREATE TABLE SP_CLAIM_MAPPING (
            ID INTEGER NOT NULL IDENTITY,
            TENANT_ID INTEGER NOT NULL,
            IDP_CLAIM VARCHAR (512) NOT NULL ,
            SP_CLAIM VARCHAR (512) NOT NULL ,
            APP_ID INTEGER NOT NULL,
            IS_REQUESTED VARCHAR(128) DEFAULT '0',
	    IS_MANDATORY VARCHAR(128) DEFAULT '0',
            DEFAULT_VALUE VARCHAR(255),
            PRIMARY KEY (ID));

ALTER TABLE SP_CLAIM_MAPPING ADD CONSTRAINT CLAIMID_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[SP_ROLE_MAPPING]') AND TYPE IN (N'U'))
CREATE TABLE SP_ROLE_MAPPING (
            ID INTEGER NOT NULL IDENTITY,
            TENANT_ID INTEGER NOT NULL,
            IDP_ROLE VARCHAR (255) NOT NULL ,
            SP_ROLE VARCHAR (255) NOT NULL ,
      	    APP_ID INTEGER NOT NULL,
            PRIMARY KEY (ID));

ALTER TABLE SP_ROLE_MAPPING ADD CONSTRAINT ROLEID_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[SP_REQ_PATH_AUTHENTICATOR]') AND TYPE IN (N'U'))
CREATE TABLE SP_REQ_PATH_AUTHENTICATOR (
            ID INTEGER NOT NULL IDENTITY,
            TENANT_ID INTEGER NOT NULL,
            AUTHENTICATOR_NAME VARCHAR (255) NOT NULL ,
            APP_ID INTEGER NOT NULL,
            PRIMARY KEY (ID));

ALTER TABLE SP_REQ_PATH_AUTHENTICATOR ADD CONSTRAINT REQ_AUTH_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[SP_PROVISIONING_CONNECTOR]') AND TYPE IN (N'U'))
CREATE TABLE SP_PROVISIONING_CONNECTOR (
            ID INTEGER NOT NULL IDENTITY,
            TENANT_ID INTEGER NOT NULL,
            IDP_NAME VARCHAR (255) NOT NULL ,
            CONNECTOR_NAME VARCHAR (255) NOT NULL ,
            APP_ID INTEGER NOT NULL,
            IS_JIT_ENABLED CHAR(1) NOT NULL DEFAULT '0',
            BLOCKING CHAR(1) NOT NULL DEFAULT '0',
            RULE_ENABLED CHAR(1) NOT NULL DEFAULT '0',
			      PRIMARY KEY (ID));

ALTER TABLE SP_PROVISIONING_CONNECTOR ADD CONSTRAINT PRO_CONNECTOR_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDP]') AND TYPE IN (N'U'))
CREATE TABLE IDP (
			ID INTEGER IDENTITY,
			TENANT_ID INTEGER,
			NAME VARCHAR(254) NOT NULL,
			IS_ENABLED CHAR(1) NOT NULL DEFAULT '1',
			IS_PRIMARY CHAR(1) NOT NULL DEFAULT '0',
			HOME_REALM_ID VARCHAR(254),
			IMAGE VARBINARY(MAX),
			CERTIFICATE VARBINARY(MAX),
			ALIAS VARCHAR(254),
			INBOUND_PROV_ENABLED CHAR (1) NOT NULL DEFAULT '0',
			INBOUND_PROV_USER_STORE_ID VARCHAR(254),
 			USER_CLAIM_URI VARCHAR(254),
 			ROLE_CLAIM_URI VARCHAR(254),
  			DESCRIPTION VARCHAR (1024),
 			DEFAULT_AUTHENTICATOR_NAME VARCHAR(254),
 			DEFAULT_PRO_CONNECTOR_NAME VARCHAR(254),
 			PROVISIONING_ROLE VARCHAR(128),
 			IS_FEDERATION_HUB CHAR(1) NOT NULL DEFAULT '0',
 			IS_LOCAL_CLAIM_DIALECT CHAR(1) NOT NULL DEFAULT '0',
			PRIMARY KEY (ID),
	        DISPLAY_NAME VARCHAR(255),
			UNIQUE (TENANT_ID, NAME));

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDP_ROLE]') AND TYPE IN (N'U'))
CREATE TABLE IDP_ROLE (
			ID INTEGER IDENTITY,
			IDP_ID INTEGER,
			TENANT_ID INTEGER,
			ROLE VARCHAR(254),
			PRIMARY KEY (ID),
			UNIQUE (IDP_ID, ROLE),
			FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDP_ROLE_MAPPING]') AND TYPE IN (N'U'))
CREATE TABLE IDP_ROLE_MAPPING (
			ID INTEGER IDENTITY,
			IDP_ROLE_ID INTEGER,
			TENANT_ID INTEGER,
			USER_STORE_ID VARCHAR (253),
			LOCAL_ROLE VARCHAR(253),
			PRIMARY KEY (ID),
			UNIQUE (IDP_ROLE_ID, TENANT_ID, USER_STORE_ID, LOCAL_ROLE),
			FOREIGN KEY (IDP_ROLE_ID) REFERENCES IDP_ROLE(ID) ON DELETE CASCADE);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDP_CLAIM]') AND TYPE IN (N'U'))
CREATE TABLE IDP_CLAIM (
			ID INTEGER IDENTITY,
			IDP_ID INTEGER,
			TENANT_ID INTEGER,
			CLAIM VARCHAR(254),
			PRIMARY KEY (ID),
			UNIQUE (IDP_ID, CLAIM),
			FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDP_CLAIM_MAPPING]') AND TYPE IN (N'U'))
CREATE TABLE IDP_CLAIM_MAPPING (
			ID INTEGER IDENTITY,
			IDP_CLAIM_ID INTEGER,
			TENANT_ID INTEGER,
			LOCAL_CLAIM VARCHAR(253),
			DEFAULT_VALUE VARCHAR(255),
	    	IS_REQUESTED VARCHAR(128) DEFAULT '0',
			PRIMARY KEY (ID),
			UNIQUE (IDP_CLAIM_ID, TENANT_ID, LOCAL_CLAIM),
			FOREIGN KEY (IDP_CLAIM_ID) REFERENCES IDP_CLAIM(ID) ON DELETE CASCADE);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDP_AUTHENTICATOR]') AND TYPE IN (N'U'))
CREATE TABLE IDP_AUTHENTICATOR (
            ID INTEGER IDENTITY,
            TENANT_ID INTEGER,
            IDP_ID INTEGER,
            NAME VARCHAR(255) NOT NULL,
            IS_ENABLED CHAR (1) DEFAULT '1',
            DISPLAY_NAME VARCHAR(255),
            PRIMARY KEY (ID),
            UNIQUE (TENANT_ID, IDP_ID, NAME),
            FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDP_METADATA]') AND TYPE IN (N'U'))
CREATE TABLE IDP_METADATA (
            ID INTEGER IDENTITY,
            IDP_ID INTEGER,
            NAME VARCHAR(255) NOT NULL,
            VALUE VARCHAR(255) NOT NULL,
            DISPLAY_NAME VARCHAR(255),
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (ID),
            CONSTRAINT IDP_METADATA_CONSTRAINT UNIQUE (IDP_ID, NAME),
            FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDP_AUTHENTICATOR_PROPERTY]') AND TYPE IN (N'U'))
CREATE TABLE IDP_AUTHENTICATOR_PROPERTY (
            ID INTEGER IDENTITY,
            TENANT_ID INTEGER,
            AUTHENTICATOR_ID INTEGER,
            PROPERTY_KEY VARCHAR(255) NOT NULL,
            PROPERTY_VALUE VARCHAR(2047),
            IS_SECRET CHAR (1) DEFAULT '0',
            PRIMARY KEY (ID),
            UNIQUE (TENANT_ID, AUTHENTICATOR_ID, PROPERTY_KEY),
            FOREIGN KEY (AUTHENTICATOR_ID) REFERENCES IDP_AUTHENTICATOR(ID) ON DELETE CASCADE);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDP_PROVISIONING_CONFIG]') AND TYPE IN (N'U'))
CREATE TABLE IDP_PROVISIONING_CONFIG (
            ID INTEGER IDENTITY,
            TENANT_ID INTEGER,
            IDP_ID INTEGER,
            PROVISIONING_CONNECTOR_TYPE VARCHAR(255) NOT NULL,
            IS_ENABLED CHAR (1) DEFAULT '0',
            IS_BLOCKING CHAR (1) DEFAULT '0',
            IS_RULES_ENABLED CHAR (1) DEFAULT '0',
            PRIMARY KEY (ID),
            UNIQUE (TENANT_ID, IDP_ID, PROVISIONING_CONNECTOR_TYPE),
            FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDP_PROV_CONFIG_PROPERTY]') AND TYPE IN (N'U'))
CREATE TABLE IDP_PROV_CONFIG_PROPERTY (
            ID INTEGER IDENTITY,
            TENANT_ID INTEGER,
            PROVISIONING_CONFIG_ID INTEGER,
            PROPERTY_KEY VARCHAR(255) NOT NULL,
            PROPERTY_VALUE VARCHAR(2048),
            PROPERTY_BLOB_VALUE VARBINARY(MAX),
            PROPERTY_TYPE CHAR(32) NOT NULL,
            IS_SECRET CHAR (1) DEFAULT '0',
            PRIMARY KEY (ID),
            UNIQUE (TENANT_ID, PROVISIONING_CONFIG_ID, PROPERTY_KEY),
            FOREIGN KEY (PROVISIONING_CONFIG_ID) REFERENCES IDP_PROVISIONING_CONFIG(ID) ON DELETE CASCADE);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDP_PROVISIONING_ENTITY]') AND TYPE IN (N'U'))
CREATE TABLE IDP_PROVISIONING_ENTITY (
            ID INTEGER IDENTITY,
            PROVISIONING_CONFIG_ID INTEGER,
            ENTITY_TYPE VARCHAR(255) NOT NULL,
            ENTITY_LOCAL_USERSTORE VARCHAR(255) NOT NULL,
            ENTITY_NAME VARCHAR(255) NOT NULL,
            ENTITY_VALUE VARCHAR(255),
            TENANT_ID INTEGER,
            ENTITY_LOCAL_ID VARCHAR(255),
            PRIMARY KEY (ID),
            UNIQUE (ENTITY_TYPE, TENANT_ID, ENTITY_LOCAL_USERSTORE, ENTITY_NAME, PROVISIONING_CONFIG_ID),
            UNIQUE (PROVISIONING_CONFIG_ID, ENTITY_TYPE, ENTITY_VALUE),
            FOREIGN KEY (PROVISIONING_CONFIG_ID) REFERENCES IDP_PROVISIONING_CONFIG(ID) ON DELETE CASCADE);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDP_LOCAL_CLAIM]') AND TYPE IN (N'U'))
CREATE TABLE IDP_LOCAL_CLAIM (
            ID INTEGER IDENTITY,
            TENANT_ID INTEGER,
            IDP_ID INTEGER,
            CLAIM_URI VARCHAR(255) NOT NULL,
            DEFAULT_VALUE VARCHAR(255),
            IS_REQUESTED VARCHAR(128) DEFAULT '0',
            PRIMARY KEY (ID),
            UNIQUE (TENANT_ID, IDP_ID, CLAIM_URI),
            FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_ASSOCIATED_ID]') AND TYPE IN (N'U'))
CREATE TABLE IDN_ASSOCIATED_ID (
            ID INTEGER IDENTITY,
            IDP_USER_ID VARCHAR(255) NOT NULL,
            TENANT_ID INTEGER DEFAULT -1234,
            IDP_ID INTEGER NOT NULL,
            DOMAIN_NAME VARCHAR(255) NOT NULL,
            USER_NAME VARCHAR(255) NOT NULL,
            PRIMARY KEY (ID),
            UNIQUE(IDP_USER_ID, TENANT_ID, IDP_ID),
            FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_USER_ACCOUNT_ASSOCIATION]') AND TYPE IN (N'U'))
CREATE TABLE IDN_USER_ACCOUNT_ASSOCIATION (
            ASSOCIATION_KEY VARCHAR(255) NOT NULL,
            TENANT_ID INTEGER,
            DOMAIN_NAME VARCHAR(255) NOT NULL,
            USER_NAME VARCHAR(255) NOT NULL,
            PRIMARY KEY (TENANT_ID, DOMAIN_NAME, USER_NAME));

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[FIDO_DEVICE_STORE]') AND TYPE IN (N'U'))
CREATE TABLE FIDO_DEVICE_STORE (
        TENANT_ID INTEGER,
        DOMAIN_NAME VARCHAR(255) NOT NULL,
        USER_NAME VARCHAR(45) NOT NULL,
	TIME_REGISTERED DATETIME,
        KEY_HANDLE VARCHAR(200) NOT NULL,
        DEVICE_DATA VARCHAR(2048) NOT NULL,
      PRIMARY KEY (TENANT_ID, DOMAIN_NAME, USER_NAME, KEY_HANDLE));

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[WF_REQUEST]') AND TYPE IN (N'U'))
CREATE TABLE WF_REQUEST (
    UUID VARCHAR (45),
    CREATED_BY VARCHAR (255),
    TENANT_ID INTEGER DEFAULT -1,
    OPERATION_TYPE VARCHAR (50),
    CREATED_AT DATETIME,
    UPDATED_AT DATETIME,
    STATUS VARCHAR (30),
    REQUEST VARBINARY(MAX),
    PRIMARY KEY (UUID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[WF_BPS_PROFILE]') AND TYPE IN (N'U'))
CREATE TABLE WF_BPS_PROFILE (
    PROFILE_NAME VARCHAR(45),
    HOST_URL_MANAGER VARCHAR(255),
    HOST_URL_WORKER VARCHAR(255),
    USERNAME VARCHAR(45),
    PASSWORD VARCHAR(1023),
    CALLBACK_HOST VARCHAR (45),
    TENANT_ID INTEGER DEFAULT -1,
    PRIMARY KEY (PROFILE_NAME, TENANT_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[WF_WORKFLOW]') AND TYPE IN (N'U'))
CREATE TABLE WF_WORKFLOW(
    ID VARCHAR (45),
    WF_NAME VARCHAR (45),
    DESCRIPTION VARCHAR (255),
    TEMPLATE_ID VARCHAR (45),
    IMPL_ID VARCHAR (45),
    TENANT_ID INTEGER DEFAULT -1,
    PRIMARY KEY (ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[WF_WORKFLOW_ASSOCIATION]') AND TYPE IN (N'U'))
CREATE TABLE WF_WORKFLOW_ASSOCIATION(
    ID INTEGER NOT NULL IDENTITY ,
    ASSOC_NAME VARCHAR (45),
    EVENT_ID VARCHAR(45),
    ASSOC_CONDITION VARCHAR (2000),
    WORKFLOW_ID VARCHAR (45),
    IS_ENABLED CHAR (1) DEFAULT '1',
    TENANT_ID INTEGER DEFAULT -1,
    PRIMARY KEY(ID),
    FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[WF_WORKFLOW_CONFIG_PARAM]') AND TYPE IN (N'U'))
CREATE TABLE WF_WORKFLOW_CONFIG_PARAM(
    WORKFLOW_ID VARCHAR (45),
    PARAM_NAME VARCHAR (45),
    PARAM_VALUE VARCHAR (1000),
    PARAM_QNAME VARCHAR (45),
    PARAM_HOLDER VARCHAR (45),
    TENANT_ID INTEGER DEFAULT -1,
    PRIMARY KEY (WORKFLOW_ID, PARAM_NAME, PARAM_QNAME, PARAM_HOLDER),
    FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[WF_REQUEST_ENTITY_RELATIONSHIP]') AND TYPE IN (N'U'))
CREATE TABLE WF_REQUEST_ENTITY_RELATIONSHIP(
  REQUEST_ID VARCHAR (45),
  ENTITY_NAME VARCHAR (255),
  ENTITY_TYPE VARCHAR (50),
  TENANT_ID INTEGER DEFAULT -1,
  PRIMARY KEY(REQUEST_ID, ENTITY_NAME, ENTITY_TYPE, TENANT_ID),
  FOREIGN KEY (REQUEST_ID) REFERENCES WF_REQUEST(UUID)ON DELETE CASCADE
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[WF_WORKFLOW_REQUEST_RELATION]') AND TYPE IN (N'U'))
CREATE TABLE WF_WORKFLOW_REQUEST_RELATION(
  RELATIONSHIP_ID VARCHAR (45),
  WORKFLOW_ID VARCHAR (45),
  REQUEST_ID VARCHAR (45),
  UPDATED_AT DATETIME,
  STATUS VARCHAR (30),
  TENANT_ID INTEGER DEFAULT -1,
  PRIMARY KEY (RELATIONSHIP_ID),
  FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE,
  FOREIGN KEY (REQUEST_ID) REFERENCES WF_REQUEST(UUID)ON DELETE CASCADE
);


IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_RECOVERY_DATA]') AND TYPE IN (N'U'))
CREATE TABLE IDN_RECOVERY_DATA (
  USER_NAME VARCHAR(255) NOT NULL,
  USER_DOMAIN VARCHAR(127) NOT NULL,
  TENANT_ID INTEGER DEFAULT -1,
  CODE VARCHAR(255) NOT NULL,
  SCENARIO VARCHAR(255) NOT NULL,
  STEP VARCHAR(127) NOT NULL,
  TIME_CREATED DATETIME NOT NULL,
  REMAINING_SETS VARCHAR(2500) DEFAULT NULL,
  PRIMARY KEY(USER_NAME, USER_DOMAIN, TENANT_ID, SCENARIO,STEP),
  UNIQUE(CODE)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_PASSWORD_HISTORY_DATA]') AND TYPE IN (N'U'))
CREATE TABLE IDN_PASSWORD_HISTORY_DATA (
  ID INTEGER NOT NULL IDENTITY ,
  USER_NAME   VARCHAR(255) NOT NULL,
  USER_DOMAIN VARCHAR(127) NOT NULL,
  TENANT_ID   INTEGER DEFAULT -1,
  SALT_VALUE  VARCHAR(255),
  HASH        VARCHAR(255) NOT NULL,
  TIME_CREATED DATETIME NOT NULL,
  PRIMARY KEY (ID),
  UNIQUE (USER_NAME,USER_DOMAIN,TENANT_ID,SALT_VALUE,HASH),
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_CLAIM_DIALECT]') AND TYPE IN (N'U'))
CREATE TABLE IDN_CLAIM_DIALECT (
  ID INTEGER NOT NULL IDENTITY,
  DIALECT_URI VARCHAR (255) NOT NULL,
  TENANT_ID INTEGER NOT NULL,
  PRIMARY KEY (ID),
  CONSTRAINT DIALECT_URI_CONSTRAINT UNIQUE (DIALECT_URI, TENANT_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_CLAIM]') AND TYPE IN (N'U'))
CREATE TABLE IDN_CLAIM (
  ID INTEGER NOT NULL IDENTITY,
  DIALECT_ID INTEGER,
  CLAIM_URI VARCHAR (255) NOT NULL,
  TENANT_ID INTEGER NOT NULL,
  PRIMARY KEY (ID),
  FOREIGN KEY (DIALECT_ID) REFERENCES IDN_CLAIM_DIALECT(ID) ON DELETE CASCADE,
  CONSTRAINT CLAIM_URI_CONSTRAINT UNIQUE (DIALECT_ID, CLAIM_URI, TENANT_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_CLAIM_MAPPED_ATTRIBUTE]') AND TYPE IN (N'U'))
CREATE TABLE IDN_CLAIM_MAPPED_ATTRIBUTE (
  ID INTEGER NOT NULL IDENTITY,
  LOCAL_CLAIM_ID INTEGER,
  USER_STORE_DOMAIN_NAME VARCHAR (255) NOT NULL,
  ATTRIBUTE_NAME VARCHAR (255) NOT NULL,
  TENANT_ID INTEGER NOT NULL,
  PRIMARY KEY (ID),
  FOREIGN KEY (LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,
  CONSTRAINT USER_STORE_DOMAIN_CONSTRAINT UNIQUE (LOCAL_CLAIM_ID, USER_STORE_DOMAIN_NAME, TENANT_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_CLAIM_PROPERTY]') AND TYPE IN (N'U'))
CREATE TABLE IDN_CLAIM_PROPERTY (
  ID INTEGER NOT NULL IDENTITY,
  LOCAL_CLAIM_ID INTEGER,
  PROPERTY_NAME VARCHAR (255) NOT NULL,
  PROPERTY_VALUE VARCHAR (255) NOT NULL,
  TENANT_ID INTEGER NOT NULL,
  PRIMARY KEY (ID),
  FOREIGN KEY (LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,
  CONSTRAINT PROPERTY_NAME_CONSTRAINT UNIQUE (LOCAL_CLAIM_ID, PROPERTY_NAME, TENANT_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_CLAIM_MAPPING]') AND TYPE IN (N'U'))
CREATE TABLE IDN_CLAIM_MAPPING (
  ID INTEGER NOT NULL IDENTITY,
  EXT_CLAIM_ID INTEGER NOT NULL,
  MAPPED_LOCAL_CLAIM_ID INTEGER NOT NULL,
  TENANT_ID INTEGER NOT NULL,
  PRIMARY KEY (ID),
  FOREIGN KEY (EXT_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE ,
  FOREIGN KEY (MAPPED_LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE NO ACTION ,
  CONSTRAINT EXT_TO_LOC_MAPPING_CONSTRN UNIQUE (EXT_CLAIM_ID, TENANT_ID)
);

IF NOT  EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[DBO].[IDN_SAML2_ASSERTION_STORE]') AND TYPE IN (N'U'))
CREATE TABLE IDN_SAML2_ASSERTION_STORE (
  ID INTEGER NOT NULL IDENTITY,
  SAML2_ID  VARCHAR(255) ,
  SAML2_ISSUER  VARCHAR(255) ,
  SAML2_SUBJECT  VARCHAR(255) ,
  SAML2_SESSION_INDEX  VARCHAR(255) ,
  SAML2_AUTHN_CONTEXT_CLASS_REF  VARCHAR(255) ,
  SAML2_ASSERTION  VARCHAR(4096) ,
  PRIMARY KEY (ID)
);
