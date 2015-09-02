# FormBuilder that allows only fields spcified in custom_attributes
class AdminFormBuilder < SimpleForm::FormBuilder
  def initialize(*) #:nodoc:
    super
    @alias_set = options[:alias_set] || 'Default'
    @table_name = @object.class.table_name
  end

  def input(attribute_name, options = {}, &block)
    return unless input_allowed? attribute_name

    super(attribute_name, options, &block)
  end

  private

    def input_allowed?(attribute_name)
      database_field = "#{@table_name}.#{attribute_name}"
      attributes = Keyword::CustomAttribute.fetch_set table_name: @table_name, set_name: @alias_set

      # If have no attributes defined, and we're using default set -> allow everything
      return true if attributes.blank? && @alias_set = 'Default'

      # Check that current attribute is marked as visible
      attributes.visible.where(database_field: database_field).present?
    end
end
