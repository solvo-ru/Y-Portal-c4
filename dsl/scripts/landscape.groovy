import com.structurizr.api.AdminApiClient
import com.structurizr.api.WorkspaceApiClient
import groovy.transform.Field
import com.structurizr.configuration.WorkspaceScope

@Field static final STRUCTURIZR_ONPREMISES_URL = 'http://structurizr.solvo.ru'
@Field static final ADMIN_API_KEY_PLAINTEXT = 'CozyPlace-36'
  
if(workspace.WorkspaceScope!="Landscape" ) break  //We only run this script for higher level workspace

/**
*   First find all existing System's workspaces and map their url's to the corresponding landscape's elements 
*   
**/

//def workspaces = getWorkspaces([2, 3, 4])

def LandscapeWorkspace = workspace
def SoftwareSystemWorkspaces = getWorkspaces()

SoftwareSystemWorkspaces.each { subWorkspace ->
    def softwareSystemFromSubWorkspace = subWorkspace.model.softwareSystems.find { !it.containers.isEmpty() }
    if (softwareSystemFromSubWorkspace) {
        LandscapeWorkspace.model.elements.find {
             getElementKey(it) == softwareSystemFromSubWorkspace.properties['structurizr.dsl.identifier'] 
        }.setUrl("{workspace:${it.id}}/diagrams")

        findElementByKey(workspace, getElementKey(softwareSystem))
                .setUrl("{workspace:${it.id}}/diagrams")
    }
}

def view = workspace.views.createSystemLandscapeView("solvo-products", "Экосистема продуктов Solvo");
view.addAllElements();

//static List getWorkspaces(List workspaceIds) {
static List getWorkspaces() {
    def adminApiClient = new AdminApiClient("${STRUCTURIZR_ONPREMISES_URL}/api", '', ADMIN_API_KEY_PLAINTEXT)
   // def workspaces = adminApiClient.workspaces.findAll { it.id in workspaceIds }
    
    def workspaces = adminApiClient.workspaces.findAll{ it.WorkspaceScope="SoftwareSystem" }

    return workspaces.collect {
        def workspaceApiClient = new WorkspaceApiClient("${STRUCTURIZR_ONPREMISES_URL}/api", it.apiKey, it.apiSecret)
        workspaceApiClient.workspaceArchiveLocation = null
        workspaceApiClient.getWorkspace(it.id)
    }
}

static findElementByKey(def workspace, String key) {
    workspace.model.elements.find { getElementKey(it) == key }
}

static String getElementKey(def element) {
    element.properties['structurizr.dsl.identifier']
}


