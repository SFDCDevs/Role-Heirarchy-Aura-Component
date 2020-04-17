/*****************************************************
 * Name : RoleTreeController
 * Developer: Vinay Vernekar
 * Website: https://sfdcdevelopers.com
 * Email: support@sfdcdevelopers.com
 * Purpose: Utility class to fetch roles and subordinates
 * Date: 16th April 2020
*******************************************************/
public class RoleTreeController {
    
    // map to hold roles with Id as the key
    private static Map <Id, UserRole> rolesMap;
    
    // map to hold child roles with parentRoleId as the key
    private static Map <Id, List<UserRole>> parentChildRoleMap;
    
    //parent role id
    private static Id ParentRoleId;
    
    // Global JSON generator
    private static JSONGenerator gen;

    
    /* // initialize helper data */ 
    static {
        init();
    }
    
    /* init starts <to initialise helper data> */
    private static void init() {
        
        // Get role to users mapping in a map with key as role id
        rolesMap = new Map<Id, UserRole>([select Id, Name, parentRoleId from UserRole where PortalType = 'None' order by Name]);
        
        // populate parent role - child roles map
        parentChildRoleMap = new Map <Id, List<UserRole>>();        
        for (UserRole r : rolesMap.values()) {
            if(ParentRoleId == null)
                ParentRoleId = R.Id;
            List<UserRole> tempList;
            if (!parentChildRoleMap.containsKey(r.parentRoleId)){
                tempList = new List<UserRole>();
                tempList.Add(r);
                parentChildRoleMap.put(r.parentRoleId, tempList);
            }
            else {
                tempList = (List<UserRole>)parentChildRoleMap.get(r.parentRoleId);
                tempList.add(r);
                parentChildRoleMap.put(r.parentRoleId, tempList);
            }
        }
    } 
    /* init ends */

    
    /* createNode starts */
    private static RoleNodeWrapper createNode(Id objId) {
        RoleNodeWrapper n = new RoleNodeWrapper();
        n.myRoleId = objId;
        n.myRoleName = rolesMap.get(objId).Name;
        
        if (parentChildRoleMap.containsKey(objId)){
            n.hasChildren = true;
            n.isLeafNode = false;
            List<RoleNodeWrapper> lst = new List<RoleNodeWrapper>();
            for (UserRole r : parentChildRoleMap.get(objId)) {
                lst.add(createNode(r.Id));
            }           
            n.myChildNodes = lst;
        }
        else {
            n.isLeafNode = true;
            n.hasChildren = false;
        }
        return n;
    }
    
    /* Invoke function from lightning component */
    @AuraEnabled
    public static String getTreeJSON() {
        gen = JSON.createGenerator(true);
        RoleNodeWrapper node = createNode(ParentRoleId);
        gen.writeStartArray();
        convertNodeToJSON(node);
        gen.writeEndArray();
        return gen.getAsString();
    }
    
    /* Convert tree structure to JSON */
    private static void convertNodeToJSON(RoleNodeWrapper objRNW){
        gen.writeStartObject();
        gen.writeStringField('label', objRNW.myRoleName);
        gen.writeStringField('name', objRNW.myRoleId);
        gen.writeBooleanField('expanded', true);
        if (objRNW.hasChildren){
            gen.writeFieldName('items');
            gen.writeStartArray();
            if (objRNW.hasChildren)
            {
                for (RoleNodeWrapper r : objRNW.myChildNodes){
                    convertNodeToJSON(r);
                }
            }
            gen.writeEndArray();
        }
        gen.writeEndObject();
    }
    
    public class RoleNodeWrapper {
        public String myRoleName {get; set;}
        public Id myRoleId {get; set;}
        public Boolean hasChildren {get; set;}
        public Boolean isLeafNode {get; set;}
        public List<RoleNodeWrapper> myChildNodes {get; set;}
        public RoleNodeWrapper(){
            hasChildren = false;
        }
    }
}