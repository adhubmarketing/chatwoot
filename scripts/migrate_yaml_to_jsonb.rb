#!/usr/bin/env ruby
# Script para migrar valores YAML para JSONB
# Uso: bundle exec rails runner scripts/migrate_yaml_to_jsonb.rb
#
# ATENÇÃO: Este script faz UPDATE no banco de dados!
# Teste em staging antes de rodar em produção.

puts "🔄 Migrando valores YAML legados para JSONB...\n\n"

dry_run = ENV['DRY_RUN'] != 'false'

if dry_run
  puts "⚠️  Modo DRY RUN ativo - nenhuma mudança será salva no banco"
  puts "   Para executar de verdade, rode: DRY_RUN=false bundle exec rails runner scripts/migrate_yaml_to_jsonb.rb\n\n"
end

migrated = 0
skipped = 0
errors = []

InstallationConfig.find_each do |config|
  val = config.serialized_value

  # Só migra se for string YAML
  next unless val.is_a?(String) && val.start_with?('---')

  begin
    # Extrai o valor usando o método atual
    extracted_value = config.value

    # Atualiza para formato JSONB
    if dry_run
      puts "  [DRY RUN] #{config.name}: '#{val[0..50]}...' → #{extracted_value.inspect}"
      migrated += 1
    else
      config.update_column(:serialized_value, { value: extracted_value })
      puts "  ✅ #{config.name}: migrado para JSONB"
      migrated += 1
    end
  rescue StandardError => e
    errors << { name: config.name, error: e.message }
    puts "  ❌ #{config.name}: erro ao migrar - #{e.message}"
  end
end

puts "\n📊 Resumo:"
puts "  Migrados: #{migrated}"
puts "  Erros:    #{errors.count}"

if dry_run
  puts "\n💡 Para executar de verdade:"
  puts "   DRY_RUN=false bundle exec rails runner scripts/migrate_yaml_to_jsonb.rb"
else
  puts "\n✅ Migração concluída!"
  puts "   Não esqueça de limpar o cache: GlobalConfig.clear_cache"
end
