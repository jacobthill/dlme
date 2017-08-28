# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transforms do
  describe 'split' do
    subject { described_class.split(['First half of the string|Second half of the string'], '|') }

    context 'With two values' do
      it 'Retuns an array of the values' do
        is_expected.to eq ['First half of the string', 'Second half of the string']
      end
    end
  end

  describe 'trim' do
    subject { described_class.trim(data, option) }

    context 'Where there is leading and trailing whitespace' do
      let(:data) { ['    This is a string with a lot of whitespace    '] }
      let(:option) { true }

      it 'Removes the leading and trailing whitespace' do
        is_expected.to eq ['This is a string with a lot of whitespace']
      end
    end

    context 'Where the input data is an array' do
      let(:data) { ['    Whitespace one    ', '    Whitespace two    '] }
      let(:option) { true }

      it 'Removes the leading and trailing whitespace from both array elements' do
        is_expected.to include 'Whitespace one'
        is_expected.to include 'Whitespace two'
      end
    end
  end

  describe 'append' do
    subject { described_class.append(data, option) }

    context 'When a string is provided to append' do
      let(:data) { ['First part of string'] }
      let(:option) { ', Second part of string' }

      it 'Adds the option string to the data string' do
        is_expected.to eq ['First part of string, Second part of string']
      end
    end

    context 'When two strings are provided to append to' do
      let(:data) { ['First part of string one', 'First part of string two'] }
      let(:option) { ', Second part of string' }

      it 'Adds the option string to both data strings' do
        is_expected.to eq ['First part of string one, Second part of string',
                           'First part of string two, Second part of string']
      end
    end
  end

  describe 'insert' do
    subject { described_class.insert(data, option) }

    context 'When a string is provided to insert' do
      let(:data) { ['right'] }
      let(:option) { 'Insert some text %s here' }

      it 'Inserts the option inside the string' do
        is_expected.to eq ['Insert some text right here']
      end
    end

    context 'When an array is provided to insert' do
      let(:data) { ['right', 'up in'] }
      let(:option) { 'Insert some text %s here' }

      it 'Inserts the option inside the strings' do
        is_expected.to include 'Insert some text right here'
        is_expected.to include 'Insert some text up in here'
      end
    end
  end
end
