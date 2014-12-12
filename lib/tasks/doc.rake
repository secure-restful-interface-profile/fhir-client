namespace :doc do

  desc 'Generates code documentation'
  task :code do
    sh "rdoc --format=fivefish --markup=markdown --main README.rdoc app lib"
  end

  desc 'Generates class diagrams'
  task :diagrams do
    sh "mkdir -p doc/diagrams"
    sh "railroady -ilamM | dot -Tsvg > doc/diagrams/models.svg"
    sh "railroady -ilamC | dot -Tsvg > doc/diagrams/controllers.svg"
  end

  desc 'Create all documentation'
  task :all => [ 'doc:code', 'doc:diagrams' ]
  
end
