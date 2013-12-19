# -*- encoding : utf-8 -*-

Fabricator(:operation_log) do
  operated_at  { sequence(:operated_at) { |i| Time.now - i.hour } }
  updated_at   { sequence(:updated_at)  { |i| Time.now - i.hour } }
  created_at   { sequence(:created_at)  { |i| Time.now - i.hour } }
  operator     { sequence(:operator)    { |i| "admin#{i}" } }
  operation    { sequence(:operation)   { |i| "操作#{i}" } }
end