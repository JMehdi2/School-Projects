*CAUSAL EFFECT OF ENGLISH LANGUAGE PRE-TRAININGS ON EMPLOYMENT OF REFUGEES IN THE USA
* By Losiangura Stephen Kaspan and Mehdi Jaddour
cd "C:\Users\Mehdi Jaddour\Desktop\Economic Analysis Master's\Causal data\Empirical Project\Analysis"
use "2019 ASR_Public_Use_File", clear

describe

*Output variable: Finding a job
	codebook ui_work
	// We consider success to be worked now or before
	drop if ui_work ==. | ui_work == 999 | ui_work == 4
	gen work =1
	replace work =0 if ui_work==3
	label variable work "Success to find a job"
	label define work 0 "Didn't find a job" 1 "Did find a job", modify
	label values work work
	codebook work
	


*Treatment variable: English training before entering the US
	codebook qn4c
	drop if qn4c==8 | qn4c==9
	gen english_train =0
	replace english_train=1 if qn4c==2
	label variable english_train "Treatment"
	label define treated 0 "Not treated" 1 "Treated", add
	label values english_train treated
	codebook english_train
	

*End 1: Disabilities
	codebook qn28b
	drop if qn28b==9 | qn28b==8
	gen disability = 0
	replace disability=1 if qn28b==2
	label variable disability "Existence of a disability that prevents from work"
	label define disab 0 "Without disability" 1 "With disability", add
	label values disability disab
	codebook disability

*End 2: Previous qualifications
	*Highest degree obtained:
		codebook qn2b, tab(100)
		drop if qn2b == 98 | qn2b==99
		label variable qn2b "Highest degree achieved before arrival to the USA"
	*Degree obtention (binary)
		gen school_bef =1
		replace school_bef=0 if qn2b==1
		label variable school_bef "Obtention of a degree before arrival to the USA"
		label define sch_bf 0 "Has no degree" 1 "Has a degree", add
		label values school_bef sch_bf
		codebook school_bef
	*Employment
		codebook qn3a, tab(100)
		drop if qn3a==98|qn3a==99
		label variable qn3a "Type of job before arrival to the USA"
	*Employment (binary)
		gen employed_bef =1
		replace employed_bef =0 if qn3a ==1 | qn3a ==6
		label variable employed_bef "Employment history before arrival to the USA"
		label define emp_bf 0 "never employed" 1 "was employed", add
		label values employed_bef emp_bf
		codebook employed_bef
		
*End 3: Gender
	codebook qn1f
	gen female = 0
	replace female=1 if qn1f==2
	label variable female "Gender is female"
	label define gend 0 "male" 1 "female", add
	label values female gend
	codebook female

*End 4: Year of arrival
	codebook qn1jyear
	drop if qn1jyear == .

*End 5: Goals other than work
	*Study:
		codebook ui_school
		drop if ui_school ==. | ui_school==999
	*Study (binary):
		gen school = 1
		replace school = 0 if ui_school==0
		label variable school "Study pursuit at USA"
		label define schl 0 "Never attended school" 1 "Attended school", add
		label values school schl
		codebook school

*End 6: Age category
	codebook ui_agect_arrival
	drop if ui_agect_arrival==999
	codebook ui_agect_arrival
	
*End 7: English level amelioration during stay in the USA
	*Level of English at the time of the interview:
		codebook qn4b
		drop if qn4b==8
		label variable qn4b "The level of English at the time of the interview"
	*Level of English at the time of the interview (binary)
		gen eng_interview =0
		replace eng_interview=1 if qn4b <3
		label variable eng_interview "Ability to speak english at the time of the interview"
		label define eng_int 0 "can't really speak english" 1 "speaks english", add
		label values eng_interview eng_int
		codebook eng_interview

keep personid respondent work english_train disability female qn1jyear eng_interview employed_bef school_bef  school ui_agect_arrival

describe
foreach varname of varlist personid-eng_interview {
		codebook `varname'
}

**Descriptve statistics

	*Proportion of treated and employed by age category, gender, employment before 	arrival to the USA, and disability
		tabstat work english_train , by(ui_agect_arrival) s(mean)
		tabstat work english_train , by(female) s(mean)
		tabstat work english_train , by(employed_bef) s(mean)
		tabstat work english_train , by(disability) s(mean)
	*Correlation matrix (gender, employment before 	arrival to the USA, disability, treatment and output)
		corr female employed_bef disability english_train work
	*Balance/unbalance of the covariates using means comparison
	foreach varname of varlist disability-eng_interview {
		display "`varname'"
		ttest `varname', by(english_train)
		}


*Simple regression:
	reg work english_train
		

	
*PSM

teffects psmatch (work) (english_train i.disability i.female i.qn1jyear i.eng_interview i.employed_bef i.school_bef  i.school i.ui_agect_arrival)


