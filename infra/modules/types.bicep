@sys.export()
@sys.description('Tags for Azure resources.')
type ResourceTags = {
  @sys.description('Additional tags for the resource.')
  *: string
}

@sys.export()
@sys.description('Core configuration for Azure resources.')
type CoreConfiguration = {
  @sys.description('The name of the resource.')
  name: string

  @sys.description('The location for the resource.')
  location: string

  // TODO Fold identity into core
  // identity: { type: 'SystemAssigned' }

  @sys.description('Tags to apply to the resource.')
  tags: ResourceTags?
}
