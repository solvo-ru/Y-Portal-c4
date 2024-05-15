import com.structurizr.model.SoftwareSystem

workspace.model.softwareSystems.each {
    addTags(it,"system")
    it.containers.each {
        addTags(it, "container")
        it.components.each { addTags(it, "component") }
    }
}


def addTags(parent, suffix) {
    def cats = ['External', 'Tool', 'Pillar', 'Product', 'Addon']
    def stype = (parent.tagsAsSet as List).intersect(cats)
    stype = stype?.size() == 1 ? "${stype[0]} [${suffix}]" : null
    parent.addTags(stype)
}