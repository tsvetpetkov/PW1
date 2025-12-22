//// PW1 Stata Command File (Oaxaca-Blinder)
clear

// Define the data label and results file name
local data_lbl "ob_data/unemployed_sur_sa_1y_avg"
local file_name "ob_lpm_estimates"

// Define the main/collected features
local main_feats sur_sa_1y_avg ///
				 age_cat_a1 age_cat_a2 age_cat_a4 age_cat_a5 age_cat_a6 ///
				 educ_cat_e1 educ_cat_e3 educ_cat_e4 ///
				 occ_cat_tech occ_cat_serv occ_cat_farm occ_cat_prod occ_cat_oper ///
				 ind_cat_agri ind_cat_mine ind_cat_cnst ind_cat_manu ind_cat_trns ind_cat_whol ind_cat_retl ind_cat_fire ind_cat_busi ind_cat_pers ind_cat_entr ind_cat_prof ind_cat_publ ///
				 married veteran urban ///
				 sur_sa_1y_avg_age_cat_a1 sur_sa_1y_avg_age_cat_a2 sur_sa_1y_avg_age_cat_a4 sur_sa_1y_avg_age_cat_a5 sur_sa_1y_avg_age_cat_a6 ///
				 sur_sa_1y_avg_educ_cat_e1 sur_sa_1y_avg_educ_cat_e3 sur_sa_1y_avg_educ_cat_e4 ///
				 sur_sa_1y_avg_occ_cat_tech sur_sa_1y_avg_occ_cat_serv sur_sa_1y_avg_occ_cat_farm sur_sa_1y_avg_occ_cat_prod sur_sa_1y_avg_occ_cat_oper ///
				 sur_sa_1y_avg_ind_cat_agri sur_sa_1y_avg_ind_cat_mine sur_sa_1y_avg_ind_cat_cnst sur_sa_1y_avg_ind_cat_manu sur_sa_1y_avg_ind_cat_trns sur_sa_1y_avg_ind_cat_whol sur_sa_1y_avg_ind_cat_retl sur_sa_1y_avg_ind_cat_fire sur_sa_1y_avg_ind_cat_busi sur_sa_1y_avg_ind_cat_pers sur_sa_1y_avg_ind_cat_entr sur_sa_1y_avg_ind_cat_prof sur_sa_1y_avg_ind_cat_publ ///
				 sur_sa_1y_avg_married sur_sa_1y_avg_veteran sur_sa_1y_avg_urban

// Define the additional features
local addl_feats state_ak state_al state_ar state_az state_co state_ct state_dc state_de state_fl state_ga state_hi state_ia state_id state_il state_in state_ks state_ky state_la state_ma state_md state_me state_mi state_mn state_mo state_ms state_mt state_nc state_nd state_ne state_nh state_nj state_nm state_nv state_ny state_oh state_ok state_or state_pa state_ri state_sc state_sd state_tn state_tx state_ut state_va state_vt state_wa state_wi state_wv state_wy ///
				 month_2 month_3 month_4 month_5 month_6 month_7 month_8 month_9 month_10 month_11 month_12

// Initialize the results collector
postutil clear
postfile results str30 lbl `main_feats' using "`file_name'.dta", replace

// Define the group category labels
local race_cats _w _b _h
local sex_cats _m _f

// Loop through categories/datasets, running regressions and collecting marginal effects estimates
foreach race in `race_cats' {
	foreach sex in `sex_cats' {
		import delimited using "`data_lbl'`race'`sex'.csv", clear
		
		quietly reg unemployed `main_feats' `addl_feats' [pw = weight]
		
		// quietly margins, dydx(`main_feats') atmeans nose post
		
		post results ("coef`race'`sex'") ///
					 (_b[sur_sa_1y_avg]) ///
					 (_b[age_cat_a1]) (_b[age_cat_a2]) (_b[age_cat_a4]) (_b[age_cat_a5]) (_b[age_cat_a6]) ///
					 (_b[educ_cat_e1]) (_b[educ_cat_e3]) (_b[educ_cat_e4]) ///
					 (_b[occ_cat_tech]) (_b[occ_cat_serv]) (_b[occ_cat_farm]) (_b[occ_cat_prod]) (_b[occ_cat_oper]) ///
					 (_b[ind_cat_agri]) (_b[ind_cat_mine]) (_b[ind_cat_cnst]) (_b[ind_cat_manu]) (_b[ind_cat_trns]) (_b[ind_cat_whol]) (_b[ind_cat_retl]) (_b[ind_cat_fire]) (_b[ind_cat_busi]) (_b[ind_cat_pers]) (_b[ind_cat_entr]) (_b[ind_cat_prof]) (_b[ind_cat_publ]) ///
					 (_b[married]) (_b[veteran]) (_b[urban]) ///
					 (_b[sur_sa_1y_avg_age_cat_a1]) (_b[sur_sa_1y_avg_age_cat_a2]) (_b[sur_sa_1y_avg_age_cat_a4]) (_b[sur_sa_1y_avg_age_cat_a5]) (_b[sur_sa_1y_avg_age_cat_a6]) ///
					 (_b[sur_sa_1y_avg_educ_cat_e1]) (_b[sur_sa_1y_avg_educ_cat_e3]) (_b[sur_sa_1y_avg_educ_cat_e4]) ///
					 (_b[sur_sa_1y_avg_occ_cat_tech]) (_b[sur_sa_1y_avg_occ_cat_serv]) (_b[sur_sa_1y_avg_occ_cat_farm]) (_b[sur_sa_1y_avg_occ_cat_prod]) (_b[sur_sa_1y_avg_occ_cat_oper]) ///
					 (_b[sur_sa_1y_avg_ind_cat_agri]) (_b[sur_sa_1y_avg_ind_cat_mine]) (_b[sur_sa_1y_avg_ind_cat_cnst]) (_b[sur_sa_1y_avg_ind_cat_manu]) (_b[sur_sa_1y_avg_ind_cat_trns]) (_b[sur_sa_1y_avg_ind_cat_whol]) (_b[sur_sa_1y_avg_ind_cat_retl]) (_b[sur_sa_1y_avg_ind_cat_fire]) (_b[sur_sa_1y_avg_ind_cat_busi]) (_b[sur_sa_1y_avg_ind_cat_pers]) (_b[sur_sa_1y_avg_ind_cat_entr]) (_b[sur_sa_1y_avg_ind_cat_prof]) (_b[sur_sa_1y_avg_ind_cat_publ]) ///
					 (_b[sur_sa_1y_avg_married]) (_b[sur_sa_1y_avg_veteran]) (_b[sur_sa_1y_avg_urban])
	}
}

// Save the estimates to CSV
postclose results
use "`file_name'.dta", clear
export delimited using "`file_name'.csv", replace