//// PW1 Stata Command File (Marginal Effects)
clear

// Define the data label and results file name
local data_lbl "me_data/unemployed_sur_sa_1y_avg"
local file_name "me_lpm_estimates"

// Initialize the results collector
postutil clear
postfile results str40 lbl sur_sa_1y_avg_nonwhite_coef sur_sa_1y_avg_nonwhite_std_err using "`file_name'.dta", replace

// Define the group category labels
local race_cats _b _h
local sex_cats _m _f
local age_cats _a1 _a2 _a3 _a4 _a5 _a6
local educ_cats _e1 _e2 _e3 _e4

// Loop through categories/datasets, running regressions and collecting marginal effects estimates
foreach race in `race_cats' {
	foreach sex in `sex_cats' {
		foreach age in `age_cats' {
			foreach educ in `educ_cats' {
				import delimited using "`data_lbl'`race'`sex'`age'`educ'.csv", clear
				
				quietly reg unemployed ///
							nonwhite sur_sa_1y_avg ///
							occ_cat_tech occ_cat_serv occ_cat_farm occ_cat_prod occ_cat_oper ///
							ind_cat_agri ind_cat_mine ind_cat_cnst ind_cat_manu ind_cat_trns ind_cat_whol ind_cat_retl ind_cat_fire ind_cat_busi ind_cat_pers ind_cat_entr ind_cat_prof ind_cat_publ ///
							married veteran urban ///
							state_ak state_al state_ar state_az state_co state_ct state_dc state_de state_fl state_ga state_hi state_ia state_id state_il state_in state_ks state_ky state_la state_ma state_md state_me state_mi state_mn state_mo state_ms state_mt state_nc state_nd state_ne state_nh state_nj state_nm state_nv state_ny state_oh state_ok state_or state_pa state_ri state_sc state_sd state_tn state_tx state_ut state_va state_vt state_wa state_wi state_wv state_wy ///
							month_2 month_3 month_4 month_5 month_6 month_7 month_8 month_9 month_10 month_11 month_12 ///
							sur_sa_1y_avg_nonwhite ///
							occ_cat_tech_nonwhite occ_cat_serv_nonwhite occ_cat_farm_nonwhite occ_cat_prod_nonwhite occ_cat_oper_nonwhite ///
							ind_cat_agri_nonwhite ind_cat_mine_nonwhite ind_cat_cnst_nonwhite ind_cat_manu_nonwhite ind_cat_trns_nonwhite ind_cat_whol_nonwhite ind_cat_retl_nonwhite ind_cat_fire_nonwhite ind_cat_busi_nonwhite ind_cat_pers_nonwhite ind_cat_entr_nonwhite ind_cat_prof_nonwhite ind_cat_publ_nonwhite ///
							married_nonwhite veteran_nonwhite urban_nonwhite ///
							state_ak_nonwhite state_al_nonwhite state_ar_nonwhite state_az_nonwhite state_co_nonwhite state_ct_nonwhite state_dc_nonwhite state_de_nonwhite state_fl_nonwhite state_ga_nonwhite state_hi_nonwhite state_ia_nonwhite state_id_nonwhite state_il_nonwhite state_in_nonwhite state_ks_nonwhite state_ky_nonwhite state_la_nonwhite state_ma_nonwhite state_md_nonwhite state_me_nonwhite state_mi_nonwhite state_mn_nonwhite state_mo_nonwhite state_ms_nonwhite state_mt_nonwhite state_nc_nonwhite state_nd_nonwhite state_ne_nonwhite state_nh_nonwhite state_nj_nonwhite state_nm_nonwhite state_nv_nonwhite state_ny_nonwhite state_oh_nonwhite state_ok_nonwhite state_or_nonwhite state_pa_nonwhite state_ri_nonwhite state_sc_nonwhite state_sd_nonwhite state_tn_nonwhite state_tx_nonwhite state_ut_nonwhite state_va_nonwhite state_vt_nonwhite state_wa_nonwhite state_wi_nonwhite state_wv_nonwhite state_wy_nonwhite ///
							month_2_nonwhite month_3_nonwhite month_4_nonwhite month_5_nonwhite month_6_nonwhite month_7_nonwhite month_8_nonwhite month_9_nonwhite month_10_nonwhite month_11_nonwhite month_12_nonwhite ///
							[pw = weight], vce(robust)
				
				// quietly margins, dydx(sur_sa_1y_avg_nonwhite) atmeans post
				post results ("`race'`sex'`age'`educ'") (_b[sur_sa_1y_avg_nonwhite]) (_se[sur_sa_1y_avg_nonwhite])
			}
		}
	}
}

// Save the estimates to CSV
postclose results
use "`file_name'.dta", clear
export delimited using "`file_name'.csv", replace