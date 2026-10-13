#pragma once

#include "literals.h"

namespace lua::bytes
{

namespace lt
{
  constexpr byte_view cannot_persist_a_s_value("cannot persist a %s value");
  constexpr byte_view cannot_persist_a_s_closure_as_it_is("cannot persist a %s closure as it is (its upvalues were changed)");
  constexpr byte_view cannot_persist_a_C_function("cannot persist a C function");
  constexpr byte_view cannot_persist_a_running_thread("cannot persist a running thread");
  constexpr byte_view cannot_persist_the_main_thread_from_a_script("cannot persist the main thread from a script");
  constexpr byte_view cannot_persist_a_thread_with_s("cannot persist a thread with %s");
  constexpr byte_view a_continuation_that_has_no_name("a continuation that has no name");
  constexpr byte_view cannot_persist_a_budget_callback_that_has_no_name("cannot persist a budget callback that has no name");
  constexpr byte_view cannot_persist_a_budget_callback_that_is_not_a_permanent("cannot persist a budget callback that is not a permanent");
  constexpr byte_view path_budget_group("<budget group>");
  constexpr byte_view path_frozen_chain("<frozen chain>");
  constexpr byte_view path_user_value_d("<user value %d>");
  constexpr byte_view bad_permanent_value_for_key_s("bad permanent value for key '%s'");
  constexpr byte_view bad_permanent_value_s_expected_got_s("bad permanent value (%s expected, got %s)");
  constexpr byte_view mm_persist("__persist");
  constexpr byte_view a_function_capturing_the_variable("a function capturing the variable");
  constexpr byte_view invalid_persisted_data_at_byte_d("invalid persisted data (at byte %d)");
  constexpr byte_view path_root("root");
  constexpr byte_view path_at(" (at ");
  constexpr byte_view a_table_changed_while_being_persisted("a table changed while being persisted");
  constexpr byte_view path_end(")");
  constexpr byte_view persist_output_stopped_by_the_writer("persist output stopped by the writer");
  constexpr byte_view the_state_is_running("the state is running");
  constexpr byte_view the_main_thread_is_frozen_use_another_thread("the main thread is frozen: use another thread of the state");
  constexpr byte_view a_frozen_main_thread_is_restored_into_an_idle_main_thread("a frozen main thread is restored into an idle main thread with an empty stack, from another thread");
  constexpr byte_view the_permanents_must_be_a_table("the permanents must be a table");
  constexpr byte_view the_setup_must_leave_the_permanents_table_or_nil(
      "the setup must leave the permanents table (key -> object) or nil");
  constexpr byte_view not_a_persisted_state("not a persisted state");
  constexpr byte_view invalid_value_index("invalid value index");
  constexpr byte_view path_registry("registry");
  constexpr byte_view path_type_metatable("type metatable");
  constexpr byte_view path_finalizer_list("finalizer list");
  constexpr byte_view path_persisting_thread("persisting thread");
  constexpr byte_view persist_from_the_main_thread_or_a_thread_the_state_holds(
      "persist from the main thread or from a thread the state holds");
  constexpr byte_view the_state_does_not_hash_as_the_persisted_one("the state does not hash as the persisted one");
  constexpr byte_view path_field_s(".%s");
  constexpr byte_view path_index_s("[%s]");
  constexpr byte_view path_string_key_s("[\"%s\"]");
  constexpr byte_view path_object_key_s("[<%s>]");
  constexpr byte_view path_key_s("<key %s>");
  constexpr byte_view path_metatable("<metatable>");
  constexpr byte_view path_upvalue_s("<upvalue %s>");
  constexpr byte_view path_upvalue_d("<upvalue %d>");
  constexpr byte_view path_stack_d("<stack %d>");
  constexpr byte_view path_permanent_key("<permanent key>");
  constexpr byte_view path_hook("<hook>");
  constexpr byte_view a_hook_not_set_by_the_debug_library_is_not_supported_yet("a hook not set by the debug library is not supported yet");
  constexpr byte_view cannot_persist_a_table_its___persist_is_false("cannot persist a table: its __persist is false");
  constexpr byte_view mm_persist_must_be_a_boolean("__persist must be a boolean");
  constexpr byte_view persisting_a_userdata_value_is_not_supported_yet("persisting a userdata value is not supported yet");
  constexpr byte_view styx_header = lit("Styx\x0a");
  constexpr byte_view persistable("persistable");
  constexpr byte_view persist("persist");
  constexpr byte_view styx("styx");
  constexpr byte_view unpersist("unpersist");
}

}
