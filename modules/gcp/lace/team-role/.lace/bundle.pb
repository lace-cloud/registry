
2.0bundle./team-role@0.0.1"¤
./team-role@0.0.1Ž
./team-role0.0.1"ö
Ý
executor_memberstring"¿Derived by Lace. The principal set of the team's executor identity in the organization's workload identity pool: the one member granted Workload Identity User on the executor service account.
î
namestring"MThe executor service account's ID in the project. The planner is <name>-plan.2Œ
6can(regex("^[a-z][a-z0-9-]{4,23}[a-z0-9]$", var.name))Rname must be 6 to 25 lowercase letters, digits or hyphens, starting with a letter.
‘
observer_roleslist(string)"oDerived by Lace. The project roles Lace's own reads of the project need, which the executor holds beside roles.
O
org_idstring";Derived by Lace. The Lace organization the team belongs to.
Ú
planner_memberstring"½Derived by Lace. The principal set of the team's planner identity in the organization's workload identity pool: the one member granted Workload Identity User on the planner service account.
°
planner_roleslist(string)"ŽDerived by Lace. The read roles the planner holds: the metadata a plan's refresh reads, and a content read only where one of roles carries it.


project_idstring"wDerived by Lace. The Google Cloud project an org admin connected, where both service accounts and their roles are made.
a
roleslist(string)"HThe project roles the executor holds, each inside the project's ceiling.
t
team_idstring"_Derived by Lace. The Lace team that owns the role: both service accounts' descriptions name it.[
executor_emailIThe email of the executor service account, which the team's Runs apply asf
planner_emailUThe email of the planner service account, which a plan on a person's machine reads as*ö
this
this@0.0.1$
executor_memberexecutor_member
namename"
observer_rolesobserver_roles"
planner_memberplanner_member 
planner_rolesplanner_roles

project_id
project_id
rolesroles
team_id	team_idBV
*
executor_email

thisexecutor_email
(
planner_email

thisplanner_emailJ.
>= 1.3$
google
hashicorp/google~> 7.0"»

this@0.0.1¬
this0.0.1"÷

executor_memberstring

namestring
 
observer_roleslist(string)

planner_memberstring

planner_roleslist(string)


project_idstring

roleslist(string)

team_idstring
executor_email
planner_email2
+resource.google_project_iam_member.executorresourcegoogle_project_iam_member"L
memberB"@
hcl9"serviceAccount:${google_service_account.executor.email}""
project
project_id"
role"
hcl
each.valueB5"3
hcl,toset(concat(var.roles, var.observer_roles))2÷
*resource.google_project_iam_member.plannerresourcegoogle_project_iam_member"K
memberA"?
hcl8"serviceAccount:${google_service_account.planner.email}""
project
project_id"
role"
hcl
each.valueB!"
hcltoset(var.planner_roles)2æ
(resource.google_service_account.executorresourcegoogle_service_account"

account_idname"2
description#"!
hcl"lace-team=${var.team_id}""5
display_name%"#
hcl"Lace team role ${var.name}""
project
project_id2ÿ
'resource.google_service_account.plannerresourcegoogle_service_account")

account_id"
hcl"${var.name}-plan""2
description#"!
hcl"lace-team=${var.team_id}"":
display_name*"(
hcl!"Lace team role ${var.name}-plan""
project
project_id2û
>resource.google_service_account_iam_member.executor_federationresource!google_service_account_iam_member"
memberexecutor_member"*
role"
 roles/iam.workloadIdentityUser"C
service_account_id-"+
hcl$google_service_account.executor.name2ø
=resource.google_service_account_iam_member.planner_federationresource!google_service_account_iam_member"
memberplanner_member"*
role"
 roles/iam.workloadIdentityUser"B
service_account_id,"*
hcl#google_service_account.planner.nameBŒ
E
executor_email3
1
(resource.google_service_account.executoremail
C
planner_email2
0
'resource.google_service_account.planneremailJ&$
google
hashicorp/google~> 7.0