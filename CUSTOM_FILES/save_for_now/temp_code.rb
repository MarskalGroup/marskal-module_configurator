#make a method
# self.add_attr_accessors(p_class_name, :both)
# self.class.send(:define_method, k.to_sym) do                    #lets create one as requested
#   eval ("@#{k} = config")
#   # instance_variable_get('@' + k.to_s)           # equivalent of an attr_reader is created here
# end
# self.class.send(:define_method, "#{p_class_name}=".to_sym) do |value|            #lets create one as requested
#   instance_variable_set("@" + p_class_name.to_s, value)   # equivalent of an attr_writer is created here
# end
#
# self.class.send(:define_method, p_class_name.to_sym) do                    #lets create one as requested
# config_class.send(:define_method, p_class_name.to_sym) do                    #lets create one as requested
#   puts "in here....................#{ "@#{p_class_name.to_s} = config"}"
#   # eval ( "instance_variable_get('@' + p_class_name.to_s) || instance_variable_get('@configsin')")
#   instance_variable_get('@' + p_class_name.to_s)
# end


# mcfg_attributes_added.each do |l_attr|
#   config_class.send(:undef_method, l_attr.to_sym)
# end
