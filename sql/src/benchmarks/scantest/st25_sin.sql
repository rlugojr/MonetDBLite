select sum(
	sin(v1)+v2+v3+v4+v5+v6+v7+v8+v9+v10+
	v11+v12+v13+v14+v15+v16+v17+v18+v19+v20+
	v21+v22+v23+v24+v25
		  )
from t25
where rownum < &1;
