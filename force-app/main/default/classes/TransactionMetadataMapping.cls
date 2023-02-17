public with sharing class TransactionMetadataMapping {
   
    static Map<String,Schema.SObjectField> fieldMapping = new  Map<String,Schema.SObjectField>{
        'First Name' => bt_stripe__Transaction__c.Meta_First_Name__c,
        'Last Name' => bt_stripe__Transaction__c.Meta_Last_Name__c,
        'Email' => bt_stripe__Transaction__c.Meta_Email__c,
        'Address' => bt_stripe__Transaction__c.Meta_Address__c,
        'City' => bt_stripe__Transaction__c.Meta_City__c,
        'State' => bt_stripe__Transaction__c.Meta_State__c,
        'Zip' => bt_stripe__Transaction__c.Meta_Zip__c,
        'Phone' => bt_stripe__Transaction__c.Meta_Phone__c,
        'revv_uid' => bt_stripe__Transaction__c.Met_Rev_UID__c,
        'Employer' => bt_stripe__Transaction__c.Meta_Employer__c,
        'Occupation' => bt_stripe__Transaction__c.Meta_Occupation__c,
        'Source URL' => bt_stripe__Transaction__c.Meta_Source_URL__c,
        'Source Code' => bt_stripe__Transaction__c.Meta_Source_Code__c,
        'Amount' => bt_stripe__Transaction__c.Meta_Amount__c,
        'UTM Source' => bt_stripe__Transaction__c.Meta_Channel_Source__c,
        'UTM Medium' => bt_stripe__Transaction__c.Meta_UTM_Medium__c,
        'UTM Campaign' => bt_stripe__Transaction__c.Meta_UTM_Campaign__c,
        'UTM Term' => bt_stripe__Transaction__c.Meta_UTM_Term__c,
        
        'UTM Content' => bt_stripe__Transaction__c.Meta_Donation_Source__c,
        'Designation' => bt_stripe__Transaction__c.Meta_Designated_Organization__c,
        'Revv Anon Donor ID'=>null ,
        'Recurring' => bt_stripe__Transaction__c.Meta_Donation_Frequency__c
    };
    
    
    
    static Map<String,Schema.SObjectField> customerFieldMapping = new  Map<String,Schema.SObjectField>{
        'First Name' => bt_stripe__Stripe_Customer__c.Meta_First_Name__c,
        'Last Name' => bt_stripe__Stripe_Customer__c.Meta_Last_Name__c,
        'Address' => bt_stripe__Stripe_Customer__c.Meta_Address__c,
        'City' => bt_stripe__Stripe_Customer__c.Meta_City__c,
        'State' => bt_stripe__Stripe_Customer__c.Meta_State__c,
        'Zip' => bt_stripe__Stripe_Customer__c.Meta_Zip__c,
        'Phone' => bt_stripe__Stripe_Customer__c.Meta_Phone__c,
        'Employer' => bt_stripe__Stripe_Customer__c.Meta_Employer__c,
        'Occupation' => bt_stripe__Stripe_Customer__c.Meta_Occupation__c,
        'Revv Anon Donor ID' => bt_stripe__Stripe_Customer__c.Meta_Revv_Anon_Donor_ID__c,
        'revv_uid' => bt_stripe__Stripe_Customer__c.Meta_Rev_UID__c
    };
    
    
    public static void doMapping(List<bt_stripe__Transaction__c> traList){
    
          for(  bt_stripe__Transaction__c tra : traList){
              Map<String,String> metadataMap = tra.bt_stripe__Metadata__c!=null? 
                                               (Map<String,String>) JSON.deserialize(tra.bt_stripe__Metadata__c, Map<String,String>.class) : new Map<String,String>();
                                               
                                               
              if(metadataMap.size() > 0){
                  for(String mtKey : fieldMapping.keySet()){
                      if(metadataMap.get(mtKey)!=null){
                          tra.put(fieldMapping.get(mtKey),getValue(metadataMap.get(mtKey),fieldMapping.get(mtKey))); 
                      }     
                  }
              }                                 
          }
    }
    
    public static void doCustomerMapping(List<bt_stripe__Stripe_Customer__c> cusList){
    
          for(  bt_stripe__Stripe_Customer__c tra : cusList){
              Map<String,String> metadataMap = tra.bt_stripe__Metadata__c!=null? 
                                               (Map<String,String>) JSON.deserialize(tra.bt_stripe__Metadata__c, Map<String,String>.class) : new Map<String,String>();
                                               
                                               
              if(metadataMap.size() > 0){
                  for(String mtKey : fieldMapping.keySet()){
                      if(metadataMap.get(mtKey)!=null && customerFieldMapping.get(mtKey)!=null){
                          tra.put(customerFieldMapping.get(mtKey),getValue(metadataMap.get(mtKey),customerFieldMapping.get(mtKey))); 
                      }     
                  }
              }                                 
          }
    }
    
    private static Object getValue(String mapValue,Schema.SObjectField fld){
        try{
            Schema.SOAPType typeOfField = fld.getDescribe().getSOAPType();
            if(typeOfField == Schema.SOAPType.String){
                return mapValue;
            }
            
            if(typeOfField == Schema.SOAPType.Double){
                return Decimal.valueof(mapValue);
            }
            if(typeOfField == Schema.SOAPType.Boolean){
                return Boolean.valueof(mapValue);
            }
        }catch(Exception e){
            system.debug(e);
        }
            //similiar add other datatype if needed - right now everything is string
        return null;   
    }
    
}