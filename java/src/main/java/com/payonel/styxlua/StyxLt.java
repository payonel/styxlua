package com.payonel.styxlua;

import com.payonel.lungolua.bytes.ByteView;

public final class StyxLt
{
  private StyxLt()
  {
  }

  public static final ByteView cannot_persist_a_s_value = ByteView.of("cannot persist a %s value");
  public static final ByteView cannot_persist_a_s_closure_as_it_is = ByteView.of("cannot persist a %s closure as it is (its upvalues were changed)");
  public static final ByteView cannot_persist_a_C_function = ByteView.of("cannot persist a C function");
  public static final ByteView cannot_persist_a_running_thread = ByteView.of("cannot persist a running thread");
  public static final ByteView cannot_persist_the_main_thread_from_a_script = ByteView.of("cannot persist the main thread from a script");
  public static final ByteView cannot_persist_a_thread_with_s = ByteView.of("cannot persist a thread with %s");
  public static final ByteView a_continuation_that_has_no_name = ByteView.of("a continuation that has no name");
  public static final ByteView cannot_persist_a_budget_callback_that_has_no_name = ByteView.of("cannot persist a budget callback that has no name");
  public static final ByteView cannot_persist_a_budget_callback_that_is_not_a_permanent = ByteView.of("cannot persist a budget callback that is not a permanent");
  public static final ByteView path_budget_group = ByteView.of("<budget group>");
  public static final ByteView path_frozen_chain = ByteView.of("<frozen chain>");
  public static final ByteView path_user_value_d = ByteView.of("<user value %d>");
  public static final ByteView bad_permanent_value_for_key_s = ByteView.of("bad permanent value for key '%s'");
  public static final ByteView bad_permanent_value_s_expected_got_s = ByteView.of("bad permanent value (%s expected, got %s)");
  public static final ByteView mm_persist = ByteView.of("__persist");
  public static final ByteView a_function_capturing_the_variable = ByteView.of("a function capturing the variable");
  public static final ByteView invalid_persisted_data_at_byte_d = ByteView.of("invalid persisted data (at byte %d)");
  public static final ByteView path_root = ByteView.of("root");
  public static final ByteView path_at = ByteView.of(" (at ");
  public static final ByteView a_table_changed_while_being_persisted = ByteView.of("a table changed while being persisted");
  public static final ByteView path_end = ByteView.of(")");
  public static final ByteView persist_output_stopped_by_the_writer = ByteView.of("persist output stopped by the writer");
  public static final ByteView the_state_is_running = ByteView.of("the state is running");
  public static final ByteView the_main_thread_is_frozen_use_another_thread = ByteView.of("the main thread is frozen: use another thread of the state");
  public static final ByteView a_frozen_main_thread_is_restored_into_an_idle_main_thread = ByteView.of("a frozen main thread is restored into an idle main thread with an empty stack, from another thread");
  public static final ByteView the_permanents_must_be_a_table = ByteView.of("the permanents must be a table");
  public static final ByteView the_setup_must_leave_the_permanents_table_or_nil = ByteView.of("the setup must leave the permanents table (key -> object) or nil");
  public static final ByteView not_a_persisted_state = ByteView.of("not a persisted state");
  public static final ByteView invalid_value_index = ByteView.of("invalid value index");
  public static final ByteView path_registry = ByteView.of("registry");
  public static final ByteView path_type_metatable = ByteView.of("type metatable");
  public static final ByteView path_finalizer_list = ByteView.of("finalizer list");
  public static final ByteView path_persisting_thread = ByteView.of("persisting thread");
  public static final ByteView persist_from_the_main_thread_or_a_thread_the_state_holds = ByteView.of("persist from the main thread or from a thread the state holds");
  public static final ByteView the_state_does_not_hash_as_the_persisted_one = ByteView.of("the state does not hash as the persisted one");
  public static final ByteView path_field_s = ByteView.of(".%s");
  public static final ByteView path_index_s = ByteView.of("[%s]");
  public static final ByteView path_string_key_s = ByteView.of("[\"%s\"]");
  public static final ByteView path_object_key_s = ByteView.of("[<%s>]");
  public static final ByteView path_key_s = ByteView.of("<key %s>");
  public static final ByteView path_metatable = ByteView.of("<metatable>");
  public static final ByteView path_upvalue_s = ByteView.of("<upvalue %s>");
  public static final ByteView path_upvalue_d = ByteView.of("<upvalue %d>");
  public static final ByteView path_stack_d = ByteView.of("<stack %d>");
  public static final ByteView path_permanent_key = ByteView.of("<permanent key>");
  public static final ByteView path_hook = ByteView.of("<hook>");
  public static final ByteView a_hook_not_set_by_the_debug_library_is_not_supported_yet = ByteView.of("a hook not set by the debug library is not supported yet");
  public static final ByteView cannot_persist_a_table_its___persist_is_false = ByteView.of("cannot persist a table: its __persist is false");
  public static final ByteView mm_persist_must_be_a_boolean = ByteView.of("__persist must be a boolean");
  public static final ByteView persisting_a_userdata_value_is_not_supported_yet = ByteView.of("persisting a userdata value is not supported yet");
  public static final ByteView styx = ByteView.of("styx");
  public static final ByteView styx_header = ByteView.of("Styx\12");
  public static final ByteView persistable = ByteView.of("persistable");
  public static final ByteView persist = ByteView.of("persist");
  public static final ByteView unpersist = ByteView.of("unpersist");
}
