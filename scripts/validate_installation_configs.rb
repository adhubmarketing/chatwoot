#!/usr/bin/env ruby
# Script para validar formatos de InstallationConfig
# Uso: bundle exec rails runner scripts/validate_installation_configs.rb

puts "🔍 Analisando formatos de serialized_value no banco de dados...\n\n"

formats = {
  jsonb_hash: 0,
  yaml_string: 0,
  simple_string: 0,
  other: 0
}

errors = []

InstallationConfig.find_each do |config|
  val = config.serialized_value

  format = case val
           when Hash
             formats[:jsonb_hash] += 1
             :jsonb_hash
           when String
             if val.start_with?('---')
               formats[:yaml_string] += 1
               :yaml_string
             else
               formats[:simple_string] += 1
               :simple_string
             end
           else
             formats[:other] += 1
             :other
           end

  # Tenta extrair o valor
  begin
    extracted_value = config.value
    status = "✅"
  rescue StandardError => e
    status = "❌"
    errors << { name: config.name, error: e.message }
  end

  puts "#{status} #{config.name.ljust(30)} | Format: #{format.to_s.ljust(15)} | Value: #{extracted_value.inspect}"
end

puts "\n📊 Resumo:\n"
puts "  JSONB Hash (novo):     #{formats[:jsonb_hash]}"
puts "  YAML String (legado):  #{formats[:yaml_string]}"
puts "  String simples:        #{formats[:simple_string]}"
puts "  Outros:                #{formats[:other]}"
puts "\n"

if errors.any?
  puts "❌ Erros encontrados:\n"
  errors.each do |err|
    puts "  - #{err[:name]}: #{err[:error]}"
  end
else
  puts "✅ Todos os configs foram lidos com sucesso!"
end

# Recomendação
if formats[:yaml_string] > 0
  puts "\n💡 Recomendação:"
  puts "   Você tem #{formats[:yaml_string]} config(s) em formato YAML legado."
  puts "   O código atual suporta ambos os formatos, mas considere migrar para JSONB:"
  puts "   bundle exec rails runner scripts/migrate_yaml_to_jsonb.rb"
end
