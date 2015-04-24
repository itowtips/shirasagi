class Circle::TempFile
  include SS::File::Model

  default_scope ->{ where(model: "circle/temp_file") }
end
