/*
 * The contents of this file are subject to the MonetDB Public
 * License Version 1.0 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at
 * http://monetdb.cwi.nl/Legal/MonetDBPL-1.0.html
 *
 * Software distributed under the License is distributed on an
 * "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * The Original Code is the Monet Database System.
 *
 * The Initial Developer of the Original Code is CWI.
 * Portions created by CWI are Copyright (C) 1997-2002 CWI.
 * All Rights Reserved.
 *
 * Contributor(s):
 * 		Martin Kersten  <Martin.Kersten@cwi.nl>
 * 		Peter Boncz  <Peter.Boncz@cwi.nl>
 * 		Niels Nes  <Niels.Nes@cwi.nl>
 * 		Stefan Manegold  <Stefan.Manegold@cwi.nl>
 */

/********************************************************************
 * SQLSetParam()
 * CLI Compliance: deprecated in ODCB 2.0 (replaced by SQLBindParameter())
 * Provided here for old (pre ODBC 3.0) applications and driver managers.
 *
 * Author: Martin van Dinther
 * Date  : 30 aug 2002
 *
 ********************************************************************/

#include "ODBCGlobal.h"

SQLRETURN SQLSetParam(
	SQLHSTMT	hStmt,
	SQLUSMALLINT	ParameterNumber,
	SQLSMALLINT	ValueType,
	SQLSMALLINT	ParameterType,
	SQLUINTEGER	LengthPrecision,
	SQLSMALLINT	ParameterScale,
	SQLPOINTER	ParameterValue,
	SQLINTEGER *	StrLen_or_Ind )
{
        /* map this call to SQLBindParameter as described in ODBC 3.0 SDK help */
	return SQLBindParameter(
			hStmt,
			ParameterNumber,
        		SQL_PARAM_INPUT_OUTPUT,
			ValueType,
			ParameterType,
			LengthPrecision,
			ParameterScale,
			ParameterValue,
			SQL_SETPARAM_VALUE_MAX,
			StrLen_or_Ind );
}
