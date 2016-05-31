#include "madx.h"

void
pro_touschek(struct in_cmd* cmd)
  /* control for touschek module */
{
  struct command* keep_beam = current_beam;
  struct name_list* nl = current_touschek->par_names;
  struct command_parameter_list* pl = current_touschek->par;
  char *filename = NULL, *table_name = NULL;
  int pos, w_file;

  (void)cmd;
  if (twiss_table == NULL) {
    warning("no TWISS table present","touschek command ignored");
    return;
  }

  if ((current_beam = find_command(twiss_table->org_sequ->name, beam_list)) == NULL)
    current_beam = find_command("default_beam", beam_list);

  pos = name_list_pos("file", nl);

  if (nl->inform[pos])
    {
      if ((filename = pl->parameters[pos]->string) == NULL)
	{
	  if (pl->parameters[pos]->call_def != NULL)
	    filename = pl->parameters[pos]->call_def->string;
	}
      if (filename == NULL) filename = permbuff("dummy");
      w_file = 1;
    }
  else w_file = 0;

  set_option("touschek_table", &w_file); /* fill only if output */

  if (w_file)
    {
      table_name = permbuff("touschek");
      touschek_table = make_table(table_name, "touschek", touschek_table_cols,
                                  touschek_table_types, current_sequ->n_nodes);
      add_to_table_list(touschek_table, table_register);
    }
  
  // LD 2016.04.19
  adjust_beam();
  probe_beam = clone_command(current_beam);
  adjust_probe_fp(0); /* sets correct gamma, beta, etc. */

  touschek_();

  if (w_file) out_table(table_name, touschek_table, filename);
  probe_beam = delete_command(probe_beam); // LD: added...
  current_beam = keep_beam;
}



