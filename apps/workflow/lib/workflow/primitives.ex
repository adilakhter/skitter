import Skitter.Component

component Skitter.Workflow.Source, in: __PRIVATE__, out: data do
  "A primitive component which provides data from the external world"

  react data do
    data ~> data
  end
end
