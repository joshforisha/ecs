defprotocol ECS.Component do
  @doc "Returns the type of component as an atom."
  def type_of(component)
end
