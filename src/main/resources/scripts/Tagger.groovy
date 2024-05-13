import com.structurizr.model.SoftwareSystem

hydrateMe(type)

def addTags(parent, suffix) {
    def cats = ['External', 'Tool', 'Pillar', 'Product', 'Addon']
    def stype = (parent.tagsAsSet as List).intersect(cats)
    stype = stype?.size() == 1 ? "${stype[0]} [${suffix}]" : null
    parent.addTags(stype)
}

def hydrateMe(type) {
    switch(type) {
        case "workspace":
            workspace.model.softwareSystems.each { addTags(it,"system") }
            break
        case "system":
            if(element) {
                element.containers.each {
                    addTags(it, "container")
                    it.components.each { addTags(it, "component") }
                }
            }
            break
        default:
            workspace.model.softwareSystems.each {
                addTags(it,"system")
                it.containers.each {
                    addTags(it, "container")
                    it.components.each { addTags(it, "component") }
                }
            }
    }
}

