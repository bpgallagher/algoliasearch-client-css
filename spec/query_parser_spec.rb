require 'spec_helper'

describe(QueryParser) do

  describe 'index' do
    it 'should create an EntryList for each prefix' do
      # Given
      record = { foo: 'bar' }
      options = { keyword: 'tim' }

      # When
      actual = QueryParser.index(record, options)

      # Then
      expect(actual).to include 't'
      expect(actual).to include 'ti'
      expect(actual).to include 'tim'
    end

    it 'should return an array for each prefix' do
      # Given
      record = { foo: 'bar' }
      options = { keyword: 'tim' }

      # When
      actual = QueryParser.index(record, options)

      # Then
      expect(actual['t']).to be_an Array
    end

    it 'should have highlight information' do
      # Given
      record = { foo: 'bar' }
      options = { keyword: 'tim' }

      # When
      actual = QueryParser.index(record, options)

      # Then
      expect(actual['ti'][0][:highlight][:keyword]).to eq 'tim'
      expect(actual['ti'][0][:highlight][:highlight]).to eq 'ti'
      expect(actual['ti'][0][:highlight][:after]).to eq 'm'
    end

    it 'should keep the record data linked to each EntryList' do
      # Given
      record = { foo: 'bar' }
      options = { keyword: 'tim' }

      # When
      actual = QueryParser.index(record, options)

      # Then
      expect(actual['t'][0][:record]).to eq record
      expect(actual['ti'][0][:record]).to eq record
      expect(actual['tim'][0][:record]).to eq record
    end

    it 'should let me override highlight data' do
      # Given
      record = { foo: 'bar' }
      options = {
        keyword: 'tim',
        highlight: {
          before: 'foo'
        }
      }

      # When
      actual = QueryParser.index(record, options)

      # Then
      expect(actual['t'][0][:highlight][:before]).to eq 'foo'
    end

    it 'should index each word of the searchable_attribute' do
      # Given
      record = { foo: 'bar' }
      options = { keyword: 'tim carry' }

      # When
      actual = QueryParser.index(record, options)

      # Then
      expect(actual).to include 'ti'
      expect(actual).to include 'car'
    end

    it 'should remember the highlight prefix for additional words' do
      # Given
      record = { foo: 'bar' }
      options = { keyword: 'tim carry' }

      # When
      actual = QueryParser.index(record, options)

      # Then
      expect(actual['car'][0][:highlight][:keyword]).to eq 'carry'
      expect(actual['car'][0][:highlight][:before]).to eq 'tim '
      expect(actual['car'][0][:highlight][:highlight]).to eq 'car'
      expect(actual['car'][0][:highlight][:after]).to eq 'ry'
    end
  end

  describe 'merge' do
    it 'should merge several EntryTables' do
      # Given
      record_1 = { foo: 'bar' }
      record_2 = { foo: 'baz' }
      entry_table_1 = QueryParser.index(record_1, keyword: 'tim')
      entry_table_2 = QueryParser.index(record_2, keyword: 'mark')

      # When
      actual = QueryParser.merge(entry_table_1, entry_table_2)

      # Then
      expect(actual).to include 't'
      expect(actual).to include 'ti'
      expect(actual).to include 'tim'
      expect(actual).to include 'm'
      expect(actual).to include 'ma'
      expect(actual).to include 'mar'
      expect(actual).to include 'mark'
    end

    it 'should group EntryTables sharing the same prefix' do
      # Given
      record_1 = { foo: 'bar' }
      record_2 = { foo: 'baz' }
      entry_table_1 = QueryParser.index(record_1, keyword: 'tim')
      entry_table_2 = QueryParser.index(record_2, keyword: 'tom')

      # When
      actual = QueryParser.merge(entry_table_1, entry_table_2)

      # Then
      expect(actual).to include 't'
      expect(actual['t'].length).to eq 2
    end
  end
end
