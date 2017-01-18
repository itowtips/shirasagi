module CompanyList
  class Initializer
    Cms::Node.plugin "company_list/search"

    Cms::Role.permission :read_company_list_companies, module_name: "company_list"
  end
end
