src_monetdblite <- function(dbdir = tempdir(), ...) {
  src_monetdb(embedded = dbdir, ...)
}

src_monetdb <- function(dbname="demo", host = "localhost", port = 50000L, user = "monetdb",
  password = "monetdb", con = FALSE, ...) {
  if (!inherits(con, "MonetDBConnection") || !DBI::dbIsValid(con)) {
    con <- DBI::dbConnect(MonetDB.R(), dbname = dbname , host = host, port = port,
      user = user, password = password, ...)
  }
  s <- dplyr::src_sql("monetdb", con, info = DBI::dbGetInfo(con))

  # this is a (dirty) hack so we don't need to depend on dplyr
  dplyrMt <- getNamespace("dplyr")$.__S3MethodsTable__.

  dplyrMt[["sql_translate_env.MonetDBConnection"]]     <- sql_translate_env.MonetDBConnection
  dplyrMt[["src_desc.src_monetdb"]]                    <- src_desc.src_monetdb
  dplyrMt[["tbl.src_monetdb"]]                         <- tbl.src_monetdb
  dplyrMt[["sample_n.tbl_monetdb"]]                    <- sample_n.tbl_monetdb
  dplyrMt[["sample_frac.tbl_monetdb"]]                 <- sample_frac.tbl_monetdb
  dplyrMt[["db_save_query.MonetDBConnection"]]         <- db_save_query.MonetDBConnection
  dplyrMt[["db_insert_into.MonetDBConnection"]]        <- db_insert_into.MonetDBConnection
  dplyrMt[["db_create_index.MonetDBConnection"]]       <- db_create_index.MonetDBConnection
  dplyrMt[["db_analyze.MonetDBConnection"]]            <- db_analyze.MonetDBConnection
  dplyrMt[["db_explain.MonetDBEmbeddedConnection"]]    <- db_explain.MonetDBEmbeddedConnection

  s
}


tbl.src_monetdb <- function(src, from, ...) {
  if(!grepl("^\\s*SELECT\\s+.*", as.character(from), ignore.case=T, perl=T)) {
    from <- dplyr::build_sql("SELECT * FROM ", dplyr::ident(from))
  }
  dplyr::tbl_sql("monetdb", src = src, from = from, ...)
}

sql_translate_env.MonetDBConnection <- function(con) {
  dplyr::sql_variant(
    scalar = dplyr::sql_translator(.parent = dplyr::base_scalar,
      `!=` = dplyr::sql_infix("<>")
    ),
    aggregate = dplyr::sql_translator(.parent = dplyr::base_agg, 
      n = function() dplyr::sql("COUNT(*)"),
      sd =  dplyr::sql_prefix("STDDEV_SAMP"),
      var = dplyr::sql_prefix("VAR_SAMP"),
      median = dplyr::sql_prefix("MEDIAN")
    ), #FIXME n_distinct
    window = dplyr::sql_translator(.parent = dplyr::base_win)
  )
}

src_desc.src_monetdb <- function(x) {
  if (inherits(x$con, "MonetDBEmbeddedConnection")) {
    paste0("MonetDBLite ", packageVersion("MonetDBLite"), " (", monetdb_embedded_env$started_dir, ")")
  } else {
    paste0("MonetDB ",x$info$monet_version, " (",x$info$monet_release, ")")
  }
}

sample_n.tbl_monetdb <- function(x, size, replace = FALSE, weight = NULL) {
  if (replace || !is.null(weight)) {
    stop("Sorry, replace and weight are not supported for MonetDB tables. \
      Consider collect()'ing first.")
  }
  DBI::dbGetQuery(x$src$con, dplyr::build_sql("SELECT * FROM (", x$query$sql, ") AS s SAMPLE ", as.integer(size)))
}

sample_frac.tbl_monetdb <- function(tbl, frac=1, replace = FALSE, weight = NULL) {
  if (frac < 0 || frac > 1) {
    stop("frac must be in [0,1]")
  }
  n <- as.integer(round(dim(tbl)[[1]] * frac))
  if (n < 1) {
    stop("not sampling 0 rows...")
  }
  dplyr::sample_n(tbl, n, replace, weight)
}

db_insert_into.MonetDBConnection <- function(con, table, values, ...) {
  DBI::dbWriteTable(con, DBI::dbQuoteIdentifier(con, table), values,
    append=T, transaction=F, csvdump=T)
}

db_save_query.MonetDBConnection <- function(con, sql, name, temporary = TRUE,
                                            ...) {
  tt_sql <- dplyr::build_sql("CREATE TEMPORARY TABLE ", dplyr::ident(name), " AS ",
    sql, " WITH DATA ON COMMIT PRESERVE ROWS", con = con)
  DBI::dbGetQuery(con, tt_sql)
  name
}

db_create_index.MonetDBConnection <- function(con, table, columns, name = NULL,
                                           ...) {
  TRUE
}

db_analyze.MonetDBConnection <- function(con, table, ...) {
  TRUE
}

db_explain.MonetDBEmbeddedConnection <- function(con, sql, ...) {
  exsql <- dplyr::build_sql("PLAN ", dplyr::sql(sql), con = con)
  expl  <- DBI::dbGetQuery(con, exsql)
  planstr <- expl[[1]][[1]]
  planstr <- gsub("\n=", "\n", planstr, perl=T)
  planstr <- gsub("^\n", "", planstr, perl=T)

  planstr
}
