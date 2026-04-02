function [muscles_new, tableLength] = ReviseMuscleParameters(muscles,muscle_lengths)
muscles_new = muscles;
muscle_names = fieldnames(muscles);
tableLength = zeros(length(muscle_names),8);

for idx_muscle = 1:length(muscle_names)
    name = muscle_names{idx_muscle};
    optimal_fiber_length = muscles.(name).optimal_fiber_length;
    tendon_slack_length = muscles.(name).tendon_slack_length;
    
    % 在站起的关节角度下，模型的肌肉长度范围
    mtp_length_range = muscles.(name).mtp_length_range;
    fiber_length_range = muscles.(name).fiber_length_range;
    tendon_length_range = muscles.(name).tendon_length_range;

    muscle_length = muscle_lengths.(name);
    muscle_length = muscle_length(floor(length(muscle_length)/3):2*floor(length(muscle_length)/3));
    aux = sort(muscle_length,'ascend');
    for i = 1:length(aux)
        if abs(aux(i)-aux(i+10))<0.01
            min_test_mtp_length = aux(i);
            break;
        end
    end
    aux = sort(muscle_length,'descend');
    for i = 1:length(aux)
        if abs(aux(i)-aux(i+10))<0.01
            max_test_mtp_length = aux(i);
            break;
        end
    end

    % l_o2 = (l_max2-l_min2)/(l_max1-l_min1)*l_o1
    % l_s2 = (l_max2-l_min2)/(l_max1-l_min1)*l_s1+(l_max1*l_min2-l_max2*l_min1)/(l_max1-l_min1)
    new_optimal_fiber_length = optimal_fiber_length*(max_test_mtp_length-min_test_mtp_length)/range(mtp_length_range);
    new_tendon_slack_length = tendon_slack_length*(max_test_mtp_length-min_test_mtp_length)/range(mtp_length_range)+...
        (mtp_length_range(2)*min_test_mtp_length-mtp_length_range(1)*max_test_mtp_length)/range(mtp_length_range);
    
    muscles_new.(name).optimal_fiber_length = new_optimal_fiber_length;
    muscles_new.(name).tendon_slack_length = new_tendon_slack_length;
    
    tableLength(idx_muscle,:) = [mtp_length_range(1),mtp_length_range(2),min_test_mtp_length,max_test_mtp_length,tendon_length_range(1),tendon_length_range(2),tendon_slack_length,optimal_fiber_length];

end

tableLength = array2table(tableLength,'RowNames',muscle_names,'VariableNames',{'模型肌肉长度最小值','模型肌肉长度最大值','数据肌肉长度最小值','数据肌肉长度最大值','模型肌腱最小值','模型肌腱最大值','模型松弛肌腱','模型最优纤维'});