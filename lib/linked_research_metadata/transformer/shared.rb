module LinkedResearchMetadata
  module Transformer

    # Shared
    #
    module Shared

      private

      def minimal_file(uri, file)
        #name
        add_triple uri, RDF::Vocab::DC.title, file.name

        #type
        add_triple uri, RDF.type, RDF::Vocab::PREMIS.File
      end

      def minimal_organisation(uri, organisation_header)
        add_triple uri, RDF.type, RDF::Vocab::FOAF.Organization
        add_triple uri, RDF::Vocab::DC.title, organisation_header.name
      end

      def minimal_person(uri, person)
        add_triple uri, RDF.type, RDF::Vocab::FOAF.Person
        add_triple uri, RDF::Vocab::FOAF.name, person.name.first_last
      end

      def minimal_project(uri, related_content_header)
        add_triple uri, RDF.type, RDF::URI.new("#{vocab(:vivo)}Project")
        add_triple uri, RDF::Vocab::DC.title, related_content_header.title
      end

      def minimal_publication(uri, related_content_header)
        if related_content_header.type == 'Dataset'
          add_triple uri, RDF.type, RDF::URI.new("#{vocab(:vivo)}Dataset")
        else
          add_triple uri, RDF.type, RDF::URI.new("#{vocab(:swpo)}Publication")
        end
        add_triple uri, RDF::Vocab::DC.title, related_content_header.title
      end

    end

  end
end