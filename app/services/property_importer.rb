# frozen_string_literal: true

class PropertyImporter < ApplicationService
  include CsvSanitizer

  def initialize(file) # rubocop:disable Lint/MissingSuper
    @file = file
  end

  def call # rubocop:disable Metrics/MethodLength
    options = {
      converters: [
        proc { |value, row|
          case row.header
          when 'acquisition_price'
            sanitize_money(value)
          when 'leasable_area'
            sanitize_area(value)
          when 'acquired_on'
            sanitize_date(value)
          else
            value
          end
        },
      ],
    }
    data = CsvParser.(@file, options)

    Property.upsert_all(data, unique_by: :external_id)  # rubocop:disable Rails/SkipsModelValidations

    property_ids = data.filter_map { |e| e['external_id'] }.uniq
    Property.where(external_id: property_ids).each do |property|
      PropertyReconciliator.call(property)
    end
  end
end
