@IsTest
public class TransactionMetadataMappingTest{

    static testmethod void testMappingOnInsert(){
        bt_stripe__Transaction__c tra = new bt_stripe__Transaction__c();
        tra.bt_stripe__Amount__c=100;
        tra.bt_stripe__Metadata__c ='{"First Name":"Allen","Last Name":"Snyder","Email":"allensnyder1217@aol.com","Address":"8310 Cairo Bend Rd","City":"Lebanon","State":"TN","Zip":"37087","Employer":"Unknown","Occupation":"Unknown","Source URL":"https://contribution.freedomworks.org/rg_electionsecurity_give?utm_source=email-rg-fw&utm_medium=pet-nat&utm_campaign=20200716-election-security-p&utm_term=rgp_rsd_tap&utm_content=","Source Code":"freedomworks-inc","Amount":"15.00","Phone":"16154991201","Recurring":"FALSE","UTM Medium":"pet-nat","UTM Campaign":"20200716-election-security-p","UTM Source":"email-rg-fw","UTM Term":"rgp_rsd_tap","revv_uid":"rv_ch_01edcfexh72ntkrawm24crmee61"}';
        
        Test.startTest();
            insert tra;
        Test.stopTest();
        
        List<bt_stripe__Transaction__c> traList = [Select Id,Meta_First_Name__c, Meta_Last_Name__c,Meta_Email__c,Meta_Address__c,Meta_City__c,
                                                    Meta_State__c,Meta_Zip__c,Meta_Phone__c,Meta_Employer__c,Meta_Occupation__c,Meta_Amount__c,
                                                    Meta_Source_URL__c,Meta_Source_Code__c,Meta_Donation_Source__c,Meta_UTM_Medium__c,Meta_UTM_Campaign__c,
                                                    Meta_UTM_Term__c,Meta_UTM_Content__c,Meta_Designated_Organization__c 
                                                    FROM  bt_stripe__Transaction__c
                                                    WHERE Id=:tra.Id];                                              
        
       system.assertEquals('Allen',traList[0].Meta_First_Name__c ); 
       system.assertEquals('Snyder',traList[0].Meta_Last_Name__c );
       system.assertEquals('allensnyder1217@aol.com',traList[0].Meta_Email__c );
       system.assertEquals('8310 Cairo Bend Rd',traList[0].Meta_Address__c );
       system.assertEquals('Lebanon',traList[0].Meta_City__c ); 
       system.assertEquals('TN',traList[0].Meta_State__c );
       system.assertEquals('16154991201',traList[0].Meta_Phone__c );
       system.assertEquals('37087',traList[0].Meta_Zip__c );
       system.assertEquals('Unknown',traList[0].Meta_Employer__c );
       system.assertEquals('Unknown',traList[0].Meta_Occupation__c ); 
       system.assertEquals('freedomworks-inc',traList[0].Meta_Source_Code__c );
       system.assertEquals('pet-nat',traList[0].Meta_UTM_Medium__c ); 
                                           
        
    }
    
    static testmethod void testMappingOnUpdate(){
        bt_stripe__Transaction__c tra = new bt_stripe__Transaction__c();
        tra.bt_stripe__Amount__c=100;
        tra.bt_stripe__Metadata__c ='{"First Name":"Allen","Last Name":"Snyder","Email":"allensnyder1217@aol.com","Address":"8310 Cairo Bend Rd","City":"Lebanon","State":"TN","Zip":"37087","Employer":"Unknown","Occupation":"Unknown","Source URL":"https://contribution.freedomworks.org/rg_electionsecurity_give?utm_source=email-rg-fw&utm_medium=pet-nat&utm_campaign=20200716-election-security-p&utm_term=rgp_rsd_tap&utm_content=","Source Code":"freedomworks-inc","Amount":"15.00","Phone":"16154991201","Recurring":"FALSE","UTM Medium":"pet-nat","UTM Campaign":"20200716-election-security-p","UTM Source":"email-rg-fw","UTM Term":"rgp_rsd_tap","revv_uid":"rv_ch_01edcfexh72ntkrawm24crmee61"}';
        insert tra;
        
        
        List<bt_stripe__Transaction__c> traList = [Select Id,Meta_First_Name__c, Meta_Last_Name__c,Meta_Email__c,Meta_Address__c,Meta_City__c,
                                                    Meta_State__c,Meta_Zip__c,Meta_Phone__c,Meta_Employer__c,Meta_Occupation__c,Meta_Amount__c,
                                                    Meta_Source_URL__c,Meta_Source_Code__c,Meta_Donation_Source__c,Meta_UTM_Medium__c,Meta_UTM_Campaign__c,
                                                    Meta_UTM_Term__c,Meta_UTM_Content__c,Meta_Designated_Organization__c 
                                                    FROM  bt_stripe__Transaction__c
                                                    WHERE Id=:tra.Id];                                              
        
       system.assertEquals('Allen',traList[0].Meta_First_Name__c ); 
       system.assertEquals('Snyder',traList[0].Meta_Last_Name__c );
       system.assertEquals('allensnyder1217@aol.com',traList[0].Meta_Email__c );
       system.assertEquals('8310 Cairo Bend Rd',traList[0].Meta_Address__c );
       system.assertEquals('Lebanon',traList[0].Meta_City__c ); 
       system.assertEquals('TN',traList[0].Meta_State__c );
       system.assertEquals('16154991201',traList[0].Meta_Phone__c );
       system.assertEquals('37087',traList[0].Meta_Zip__c );
       system.assertEquals('Unknown',traList[0].Meta_Employer__c );
       system.assertEquals('Unknown',traList[0].Meta_Occupation__c ); 
       system.assertEquals('freedomworks-inc',traList[0].Meta_Source_Code__c );
       system.assertEquals('pet-nat',traList[0].Meta_UTM_Medium__c ); 
        
        Test.startTest();
            tra.bt_stripe__Metadata__c ='{"First Name":"Allen","Last Name":"Snyder","Email":"allensnyder@aol.com","Address":"8310 Cairo Bend Rd","City":"Lebanon","State":"TN","Zip":"37087","Employer":"Unknown","Occupation":"Unknown","Source URL":"https://contribution.freedomworks.org/rg_electionsecurity_give?utm_source=email-rg-fw&utm_medium=pet-nat&utm_campaign=20200716-election-security-p&utm_term=rgp_rsd_tap&utm_content=","Source Code":"freedomworks-inc","Amount":"15.00","Phone":"16154991201","Recurring":"FALSE","UTM Medium":"pet-nat","UTM Campaign":"20200716-election-security-p","UTM Source":"email-rg-fw","UTM Term":"rgp_rsd_tap","revv_uid":"rv_ch_01edcfexh72ntkrawm24crmee61"}';
              update tra;
        Test.stopTest();
        
        traList = [Select Id,Meta_First_Name__c, Meta_Last_Name__c,Meta_Email__c,Meta_Address__c,Meta_City__c,
                                                    Meta_State__c,Meta_Zip__c,Meta_Phone__c,Meta_Employer__c,Meta_Occupation__c,Meta_Amount__c,
                                                    Meta_Source_URL__c,Meta_Source_Code__c,Meta_Donation_Source__c,Meta_UTM_Medium__c,Meta_UTM_Campaign__c,
                                                    Meta_UTM_Term__c,Meta_UTM_Content__c,Meta_Designated_Organization__c 
                                                    FROM  bt_stripe__Transaction__c
                                                    WHERE Id=:tra.Id];                                              
        
       system.assertEquals('Allen',traList[0].Meta_First_Name__c ); 
       system.assertEquals('Snyder',traList[0].Meta_Last_Name__c );
       system.assertEquals('allensnyder@aol.com',traList[0].Meta_Email__c );
       system.assertEquals('8310 Cairo Bend Rd',traList[0].Meta_Address__c );
       system.assertEquals('Lebanon',traList[0].Meta_City__c ); 
       system.assertEquals('TN',traList[0].Meta_State__c );
       system.assertEquals('16154991201',traList[0].Meta_Phone__c );
       system.assertEquals('37087',traList[0].Meta_Zip__c );
       system.assertEquals('Unknown',traList[0].Meta_Employer__c );
       system.assertEquals('Unknown',traList[0].Meta_Occupation__c ); 
       system.assertEquals('freedomworks-inc',traList[0].Meta_Source_Code__c );
       system.assertEquals('pet-nat',traList[0].Meta_UTM_Medium__c ); 
                                           
        
    }
    
     static testmethod void testCustomerMappingOnInsert(){
        bt_stripe__Stripe_Settings__c settings = new bt_stripe__Stripe_Settings__c();
        settings.bt_stripe__Disable_All_Triggers__c = true;
        insert settings;
        
        bt_stripe__Stripe_Customer__c cus = new bt_stripe__Stripe_Customer__c();
        cus.Name='Allen';
        cus.bt_stripe__Metadata__c ='{"First Name":"Allen","Last Name":"Snyder","Email":"allensnyder1217@aol.com","Address":"8310 Cairo Bend Rd","City":"Lebanon","State":"TN","Zip":"37087","Employer":"Unknown","Occupation":"Unknown","Source URL":"https://contribution.freedomworks.org/rg_electionsecurity_give?utm_source=email-rg-fw&utm_medium=pet-nat&utm_campaign=20200716-election-security-p&utm_term=rgp_rsd_tap&utm_content=","Source Code":"freedomworks-inc","Amount":"15.00","Phone":"16154991201","Recurring":"FALSE","UTM Medium":"pet-nat","UTM Campaign":"20200716-election-security-p","UTM Source":"email-rg-fw","UTM Term":"rgp_rsd_tap","revv_uid":"rv_ch_01edcfexh72ntkrawm24crmee61"}';
        
        Test.startTest();
            insert cus;
        Test.stopTest();
        
        List<bt_stripe__Stripe_Customer__c> traList = [Select Id,Meta_First_Name__c, Meta_Last_Name__c,Meta_Address__c,Meta_City__c,
                                                    Meta_State__c,Meta_Zip__c,Meta_Phone__c,Meta_Employer__c,Meta_Occupation__c
                                                    FROM  bt_stripe__Stripe_Customer__c
                                                    WHERE Id=:cus.Id];                                              
        
       system.assertEquals('Allen',traList[0].Meta_First_Name__c ); 
       system.assertEquals('Snyder',traList[0].Meta_Last_Name__c );
       
       system.assertEquals('8310 Cairo Bend Rd',traList[0].Meta_Address__c );
       system.assertEquals('Lebanon',traList[0].Meta_City__c ); 
       system.assertEquals('TN',traList[0].Meta_State__c );
       system.assertEquals('16154991201',traList[0].Meta_Phone__c );
       system.assertEquals('37087',traList[0].Meta_Zip__c );
       system.assertEquals('Unknown',traList[0].Meta_Employer__c );
       system.assertEquals('Unknown',traList[0].Meta_Occupation__c ); 
       
                                           
        
    }
    
    static testmethod void testCustomerMappingOnUpdate(){
        bt_stripe__Stripe_Settings__c settings = new bt_stripe__Stripe_Settings__c();
        settings.bt_stripe__Disable_All_Triggers__c = true;
        insert settings;
        
        bt_stripe__Stripe_Customer__c cus = new bt_stripe__Stripe_Customer__c();
        cus.Name='Allen';
        cus.bt_stripe__Metadata__c ='{"First Name":"Allen","Last Name":"Snyder","Email":"allensnyder1217@aol.com","Address":"8310 Cairo Bend Rd","City":"Lebanon","State":"TN","Zip":"37087","Employer":"Unknown","Occupation":"Unknown","Source URL":"https://contribution.freedomworks.org/rg_electionsecurity_give?utm_source=email-rg-fw&utm_medium=pet-nat&utm_campaign=20200716-election-security-p&utm_term=rgp_rsd_tap&utm_content=","Source Code":"freedomworks-inc","Amount":"15.00","Phone":"16154991201","Recurring":"FALSE","UTM Medium":"pet-nat","UTM Campaign":"20200716-election-security-p","UTM Source":"email-rg-fw","UTM Term":"rgp_rsd_tap","revv_uid":"rv_ch_01edcfexh72ntkrawm24crmee61"}';
        
        insert cus;
        
        
        List<bt_stripe__Stripe_Customer__c> traList = [Select Id,Meta_First_Name__c, Meta_Last_Name__c,Meta_Address__c,Meta_City__c,
                                                    Meta_State__c,Meta_Zip__c,Meta_Phone__c,Meta_Employer__c,Meta_Occupation__c
                                                    
                                                    FROM  bt_stripe__Stripe_Customer__c
                                                    WHERE Id=:cus.Id];                                              
        
       system.assertEquals('Allen',traList[0].Meta_First_Name__c ); 
       system.assertEquals('Snyder',traList[0].Meta_Last_Name__c );  
       system.assertEquals('8310 Cairo Bend Rd',traList[0].Meta_Address__c );
       system.assertEquals('Lebanon',traList[0].Meta_City__c ); 
       system.assertEquals('TN',traList[0].Meta_State__c );
       system.assertEquals('16154991201',traList[0].Meta_Phone__c );
       system.assertEquals('37087',traList[0].Meta_Zip__c );
       system.assertEquals('Unknown',traList[0].Meta_Employer__c );
       system.assertEquals('Unknown',traList[0].Meta_Occupation__c ); 
       
        
        Test.startTest();
            cus.bt_stripe__Metadata__c ='{"First Name":"Allen2","Last Name":"Snyder","Email":"allensnyder@aol.com","Address":"8310 Cairo Bend Rd","City":"Lebanon","State":"TN","Zip":"37087","Employer":"Unknown","Occupation":"Unknown","Source URL":"https://contribution.freedomworks.org/rg_electionsecurity_give?utm_source=email-rg-fw&utm_medium=pet-nat&utm_campaign=20200716-election-security-p&utm_term=rgp_rsd_tap&utm_content=","Source Code":"freedomworks-inc","Amount":"15.00","Phone":"16154991201","Recurring":"FALSE","UTM Medium":"pet-nat","UTM Campaign":"20200716-election-security-p","UTM Source":"email-rg-fw","UTM Term":"rgp_rsd_tap","revv_uid":"rv_ch_01edcfexh72ntkrawm24crmee61"}';
              update cus;
        Test.stopTest();
        
        traList = [Select Id,Meta_First_Name__c, Meta_Last_Name__c,Meta_Address__c,Meta_City__c,
                                                    Meta_State__c,Meta_Zip__c,Meta_Phone__c,Meta_Employer__c,Meta_Occupation__c
                                                    
                                                    FROM  bt_stripe__Stripe_Customer__c
                                                    WHERE Id=:cus.Id];                                              
        
       system.assertEquals('Allen2',traList[0].Meta_First_Name__c ); 
       system.assertEquals('Snyder',traList[0].Meta_Last_Name__c );
       system.assertEquals('8310 Cairo Bend Rd',traList[0].Meta_Address__c );
       system.assertEquals('Lebanon',traList[0].Meta_City__c ); 
       system.assertEquals('TN',traList[0].Meta_State__c );
       system.assertEquals('16154991201',traList[0].Meta_Phone__c );
       system.assertEquals('37087',traList[0].Meta_Zip__c );
       system.assertEquals('Unknown',traList[0].Meta_Employer__c );
       system.assertEquals('Unknown',traList[0].Meta_Occupation__c );       
    }
    @isTest
    Public static void Method1(){
        Lead ld = new Lead(LastName='Test',Email='test@test.com',company='test'); Insert ld;
         bt_stripe__Transaction__c tra = new bt_stripe__Transaction__c();
        tra.bt_stripe__Amount__c=100;
        tra.BT_STRIPE__RELATED_LEAD__C= ld.Id;
        tra.BT_STRIPE__TRANSACTION_STATUS__C ='Completed';
        tra.BT_STRIPE__PAYMENT_STATUS__C ='Captured';
        tra.BT_STRIPE__PROCESSED_DATE__C = System.now();
        tra.CREATED_BY_VIRTUAL_TERMINAL__C = true;
        tra.bt_stripe__Metadata__c ='{"First Name":"Allen","Last Name":"Snyder","Email":"allensnyder1217@aol.com","Address":"8310 Cairo Bend Rd","City":"Lebanon","State":"TN","Zip":"37087","Employer":"Unknown","Occupation":"Unknown","Source URL":"https://contribution.freedomworks.org/rg_electionsecurity_give?utm_source=email-rg-fw&utm_medium=pet-nat&utm_campaign=20200716-election-security-p&utm_term=rgp_rsd_tap&utm_content=","Source Code":"freedomworks-inc","Amount":"15.00","Phone":"16154991201","Recurring":"FALSE","UTM Medium":"pet-nat","UTM Campaign":"20200716-election-security-p","UTM Source":"email-rg-fw","UTM Term":"rgp_rsd_tap","revv_uid":"rv_ch_01edcfexh72ntkrawm24crmee61"}';
        
        Test.startTest();
            insert tra;
            String sch = '0 0 23 * * ?'; 
            system.schedule('test', sch, new LeadConversionBatch()); 
        Test.stopTest();    
    }
    @isTest
    Public static void Method2(){
        Lead ld = new Lead(LastName='Test',Email='test@test.com',company='test'); Insert ld;
         bt_stripe__Transaction__c tra = new bt_stripe__Transaction__c();
        tra.bt_stripe__Amount__c=100;
        tra.BT_STRIPE__RELATED_LEAD__C= ld.Id;
        tra.BT_STRIPE__TRANSACTION_STATUS__C ='Completed';
        tra.BT_STRIPE__PAYMENT_STATUS__C ='';
        tra.BT_STRIPE__PROCESSED_DATE__C = System.now();
        tra.CREATED_BY_VIRTUAL_TERMINAL__C = true;
        tra.bt_stripe__Metadata__c ='{"First Name":"Allen","Last Name":"Snyder","Email":"allensnyder1217@aol.com","Address":"8310 Cairo Bend Rd","City":"Lebanon","State":"TN","Zip":"37087","Employer":"Unknown","Occupation":"Unknown","Source URL":"https://contribution.freedomworks.org/rg_electionsecurity_give?utm_source=email-rg-fw&utm_medium=pet-nat&utm_campaign=20200716-election-security-p&utm_term=rgp_rsd_tap&utm_content=","Source Code":"freedomworks-inc","Amount":"15.00","Phone":"16154991201","Recurring":"FALSE","UTM Medium":"pet-nat","UTM Campaign":"20200716-election-security-p","UTM Source":"email-rg-fw","UTM Term":"rgp_rsd_tap","revv_uid":"rv_ch_01edcfexh72ntkrawm24crmee61"}';
        
        Test.startTest();
            insert tra;
            tra.BT_STRIPE__PAYMENT_STATUS__C ='Captured';
            update tra;
        Test.stopTest();    
    }
}